/*
   Copyright 2015 Rovert Jervis

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */
namespace parasol:x86_64;
/*
 * This file annotates an expression parse tree to mark those sub-trees that can be resolved as address modes.
 * 
 * By noting combinations of nodes as address modes, later stages of processing can avoid generating extra 
 * temporaries or code.
 * 
 * This code should be called before the Sethi-Ullman numbers have been assigned, since address modes will
 * reduce the register pressure. 
 */
import parasol:compiler.Binary;
import parasol:compiler.Call;
import parasol:compiler.CompileContext;
import parasol:compiler.Constant;
import parasol:compiler.EllipsisArguments;
import parasol:compiler.FunctionType;
import parasol:compiler.Node;
import parasol:compiler.NodeList;
import parasol:compiler.Operator;
import parasol:compiler.OverloadInstance;
import parasol:compiler.Selection;
import parasol:compiler.StorageClass;
import parasol:compiler.Symbol;
import parasol:compiler.Target;
import parasol:compiler.Ternary;
import parasol:compiler.Type;
import parasol:compiler.TypeFamily;
import parasol:compiler.Unary;

int MC_REG = 1;
int MC_CONST = 2;
int MC_ADDRESS = 4;
int MC_FULL = MC_REG|MC_CONST|MC_ADDRESS;

int justRegs(int modeContext) {
	return modeContext & MC_REG;
}
class X86_64AddressModes extends X86_64Encoder {
	void markAddressModes(ref<Node> node, ref<CompileContext> compileContext) {
		if (node.deferGeneration())
			return;
//		printf("-<<-\n");
//		node.print(0);
//		printf("->>-\n");
		int modeComplexity = MC_FULL;
		int nClass = nodeClasses[node.op()];
		switch (node.op()) {
		case	CALL:
			ref<Call> call = ref<Call>(node);
			if (!call.folded()) {
				call.print(0);
				assert(false);
			}
			for (ref<NodeList> args = call.arguments(); args != null; args = args.next)
				markAddressModes(args.node, compileContext);
			for (ref<NodeList> args = call.stackArguments(); args != null; args = args.next)
				markAddressModes(args.node, compileContext);
			break;
			
		case	MULTIPLY_ASSIGN:
			ref<Binary> b = ref<Binary>(node);
			modeComplexity = tryMakeMode(b.left(), MC_ADDRESS|MC_REG, nClass, compileContext);
			tryMakeMode(b.right(), modeComplexity & ~MC_CONST, nClass, compileContext);
			break;

		case	INITIALIZE:
			b = ref<Binary>(node);
			b.left().flags |= ADDRESS_MODE;
			if (b.right().op() == Operator.CALL)
				markAddressModes(b.right(), compileContext);
			else
				tryMakeMode(b.right(), MC_REG|MC_CONST, nClass, compileContext);
			break;

		case	CLASS_COPY:
			b = ref<Binary>(node);
			markAddressModes(b.left(), compileContext);
			markAddressModes(b.right(), compileContext);
			break;

		case	CLASS_OF:
			u = ref<Unary>(node);
			switch (u.operand().type.family()) {
			case	VAR:
				tryMakeMode(u.operand(), MC_ADDRESS|MC_REG, nClass, compileContext);
				break;
				
			case	CLASS:
				if (u.operand().type.indirectType(compileContext) != null) {
					tryMakeMode(u.operand(), MC_ADDRESS|MC_REG, nClass, compileContext);
					break;
				}
			default:
				markAddressModes(u.operand(), compileContext);
			}
			break;
			
		case	ASSIGN:
		case	ADD_ASSIGN:
		case	SUBTRACT_ASSIGN:
		case	DIVIDE_ASSIGN:
		case	REMAINDER_ASSIGN:
		case	LEFT_SHIFT_ASSIGN:
		case	RIGHT_SHIFT_ASSIGN:
		case	UNSIGNED_RIGHT_SHIFT_ASSIGN:
		case	OR_ASSIGN:
		case	AND_ASSIGN:
		case	EXCLUSIVE_OR_ASSIGN:
			b = ref<Binary>(node);
			if (b.left().op() == Operator.SEQUENCE) {
				b.print(0);
				assert(false);
//				markMultiAssignLvalue(b.left(), compileContext);
				assert(b.right().op() == Operator.SEQUENCE);
				ref<Binary> right = ref<Binary>(b.right());
				markAddressModes(right.left(), compileContext);
				// Leave right.right() alone - the multi-store code will take care of everything.
			} else {
				modeComplexity = tryMakeMode(b.left(), MC_ADDRESS|MC_REG, nClass, compileContext);
				tryMakeMode(b.right(), modeComplexity, nClass, compileContext);
			}
			break;

		case	EQUALITY:
		case	GREATER:
		case	GREATER_EQUAL:
		case	LESS:
		case	LESS_EQUAL:
		case	LESS_GREATER:
		case	LESS_GREATER_EQUAL:
		case	NOT_EQUAL:
		case	NOT_GREATER:
		case	NOT_GREATER_EQUAL:
		case	NOT_LESS:
		case	NOT_LESS_EQUAL:
		case	NOT_LESS_GREATER:
		case	NOT_LESS_GREATER_EQUAL:
			b = ref<Binary>(node);
			if (b.left().type.isFloat()) {
				markAddressModes(b.left(), compileContext);
				modeComplexity = MC_ADDRESS|MC_REG;
			} else {
				modeComplexity = tryMakeMode(b.left(), MC_ADDRESS|MC_REG, nClass, compileContext);
				if (b.right().op() == Operator.INTEGER)
					modeComplexity = MC_CONST;
			}
			tryMakeMode(b.right(), modeComplexity, nClass, compileContext);
			break;

		case	THIS:
		case	SUPER:
		case	TRUE:
		case	FALSE:
		case	IDENTIFIER:
		case	VARIABLE:
		case	EMPTY:
		case	STRING:
		case	INTEGER:
		case	NULL:
		case	TEMPLATE_INSTANCE:
		case	BYTES:
		case	CHARACTER:
		case	FLOATING_POINT:
			break;
			
		case	RIGHT_SHIFT:
		case	UNSIGNED_RIGHT_SHIFT:
		case	LEFT_SHIFT:
			b = ref<Binary>(node);
			if (b.right().op() == Operator.INTEGER) {
				b.right().flags |= ADDRESS_MODE;
				markAddressModes(b.left(), compileContext);
				break;
			}
			b = ref<Binary>(node);
			markAddressModes(b.left(), compileContext);
			markAddressModes(b.right(), compileContext);
			break;
			
		case	LOGICAL_AND:
		case	LOGICAL_OR:
		case	SEQUENCE:
			b = ref<Binary>(node);
			markAddressModes(b.left(), compileContext);
			markAddressModes(b.right(), compileContext);
			break;			
			
		case	LEFT_SHIFT_ASSIGN:
		case	RIGHT_SHIFT_ASSIGN:
		case	UNSIGNED_RIGHT_SHIFT_ASSIGN:
			b = ref<Binary>(node);
			if (b.right().op() == Operator.INTEGER)
				b.right().flags |= ADDRESS_MODE;
			tryMakeMode(b.left(), modeComplexity, nClass, compileContext);
			markAddressModes(b.right(), compileContext);
			break;
			
		case	DOT:
			ref<Selection> dot = ref<Selection>(node);
			if (dot.indirect())
				tryMakeIndirectMode(dot.left(), compileContext);
			else
				tryMakeMode(dot.left(), MC_ADDRESS, nClass, compileContext);
			break;
			
		case	SUBSCRIPT:
		case	DELETE:
			b = ref<Binary>(node);
			markAddressModes(b.left(), compileContext);
			markAddressModes(b.right(), compileContext);
			break;
			
		case	INDIRECT:
			ref<Unary> u = ref<Unary>(node);
			tryMakeIndirectMode(u.operand(), compileContext);
			break;
			
		case	CONDITIONAL:
			ref<Ternary> conditional = ref<Ternary>(node);
			markAddressModes(conditional.left(), compileContext);
			markAddressModes(conditional.middle(), compileContext);
			markAddressModes(conditional.right(), compileContext);
			break;
			
		case	INCREMENT_AFTER:
		case	DECREMENT_AFTER:
		case	INCREMENT_BEFORE:
		case	DECREMENT_BEFORE:
			u = ref<Unary>(node);
			tryMakeMode(u.operand(), modeComplexity, nClass, compileContext);
			break;
			
		case	BIT_COMPLEMENT:
		case	UNARY_PLUS:
		case	NEGATE:
		case	NOT:
			u = ref<Unary>(node);
			markAddressModes(u.operand(), compileContext);
			break;
			
		case	CAST:
			u = ref<Unary>(node);
			markCast(u, u.operand(), compileContext);
			break;
			
		case	ADDRESS:
			u = ref<Unary>(node);
			tryMakeMode(u.operand(), MC_ADDRESS, nClass, compileContext);
			break;
			
		case	NEW:
			b = ref<Binary>(node);
			if (b.right().op() == Operator.CALL)
				tryMakeMode(b.right(), modeComplexity, nClass, compileContext);
			else if (b.right().op() != Operator.EMPTY) {
				b.print(0);
				assert(false);
			}
			tryMakeMode(b.left(), 0, nClass, compileContext);
			break;
					
		case	ADD:
		case	SUBTRACT:
		case	REMAINDER:
		case	DIVIDE:
		case	MULTIPLY:
		case	AND:
		case	OR:
		case	EXCLUSIVE_OR:
			b = ref<Binary>(node);
			tryMakeMode(b.right(), modeComplexity, nClass, compileContext);
			tryMakeMode(b.left(), 0, nClass, compileContext);
			break;
					
		case	VACATE_ARGUMENT_REGISTERS:
			break;
			
		case	ELLIPSIS_ARGUMENTS:
			ref<EllipsisArguments> ea = ref<EllipsisArguments>(node);
			for (ref<NodeList> args = ea.arguments(); args != null; args = args.next)
				markAddressModes(args.node, compileContext);
			break;
			
		case	ELLIPSIS_ARGUMENT:
		case	STACK_ARGUMENT:
		case	LOAD:
			u = ref<Unary>(node);
			markAddressModes(u.operand(), compileContext);
			break;
			
		default:
			node.print(0);
			assert(false);
		}
	}

	void markCast(ref<Node> dest, ref<Node> operand, ref<CompileContext> compileContext) {
		ref<Type> existingType = operand.type;
		ref<Type> newType = dest.type;
		switch (existingType.family()) {
		case	BOOLEAN:
		case	UNSIGNED_8:
			switch (newType.family()) {
			case	BOOLEAN:
			case	UNSIGNED_8:
			case	UNSIGNED_16:
			case	UNSIGNED_32:
			case	SIGNED_16:
			case	SIGNED_32:
			case	SIGNED_64:
			case	ENUM:
			case	ADDRESS:
			case	FUNCTION:
			case	FLOAT_32:
			case	FLOAT_64:
				markAddressModes(operand, compileContext);
				return;

			case	CLASS:
				if (newType.indirectType(compileContext) != null) {
					markAddressModes(operand, compileContext);
					return;
				}
				break;
			}
			break;
			
		case	UNSIGNED_16:
		case	SIGNED_16:
			switch (newType.family()) {
			case	BOOLEAN:
			case	UNSIGNED_8:
			case	UNSIGNED_16:
			case	UNSIGNED_32:
			case	SIGNED_16:
			case	SIGNED_32:
			case	SIGNED_64:
			case	ADDRESS:
			case	FUNCTION:
				tryMakeMode(operand, MC_FULL, 0, compileContext);
				return;

			case	ENUM:
			case	FLOAT_32:
			case	FLOAT_64:
				markAddressModes(operand, compileContext);
				return;

			case	CLASS:
				if (newType.indirectType(compileContext) != null) {
					markAddressModes(operand, compileContext);
					return;
				}
				break;
			}
			break;
			
		case	UNSIGNED_32:
		case	SIGNED_32:
			switch (newType.family()) {
			case	BOOLEAN:
			case	UNSIGNED_8:
			case	UNSIGNED_16:
			case	UNSIGNED_32:
			case	SIGNED_16:
			case	SIGNED_32:
			case	SIGNED_64:
			case	ADDRESS:
			case	FUNCTION:
				tryMakeMode(operand, MC_FULL, 0, compileContext);
				return;
				
			case	FLOAT_32:
			case	FLOAT_64:
			case	ENUM:
				markAddressModes(operand, compileContext);
				return;

			case	CLASS:
				if (newType.indirectType(compileContext) != null) {
					tryMakeMode(operand, MC_FULL, 0, compileContext);
					return;
				}
				break;
			}
			break;

		case	SIGNED_64:
			switch (newType.family()) {
			case	BOOLEAN:
			case	UNSIGNED_8:
			case	UNSIGNED_16:
			case	UNSIGNED_32:
			case	SIGNED_16:
			case	SIGNED_32:
			case	SIGNED_64:
			case	ADDRESS:
			case	FUNCTION:
				tryMakeMode(operand, MC_FULL, 0, compileContext);
				return;

			case	FLOAT_32:
			case	FLOAT_64:
			case	ENUM:
				markAddressModes(operand, compileContext);
				return;

			case	CLASS:
				if (newType.indirectType(compileContext) != null) {
					tryMakeMode(operand, MC_FULL, 0, compileContext);
					return;
				}
				break;
			}
			break;

		case	FLOAT_32:
		case	FLOAT_64:
			switch (newType.family()) {
			case	BOOLEAN:
			case	UNSIGNED_8:
			case	UNSIGNED_16:
			case	UNSIGNED_32:
			case	SIGNED_16:
			case	SIGNED_32:
			case	SIGNED_64:
			case	ADDRESS:
			case	FUNCTION:
			case	ENUM:
				markAddressModes(operand, compileContext);
				return;

			case	FLOAT_32:
			case	FLOAT_64:
				tryMakeMode(operand, MC_FULL, 0, compileContext);
				return;

			case	CLASS:
				if (newType.indirectType(compileContext) != null) {
					markAddressModes(operand, compileContext);
					return;
				}
				break;
			}
			break;
			
		case	STRING:
			switch (newType.family()) {
			case	STRING:
				tryMakeMode(operand, MC_FULL, 0, compileContext);
				return;
			}
			break;

		case	ADDRESS:
			switch (newType.family()) {
			case	STRING:
			case	ADDRESS:
			case	SIGNED_32:
			case	FUNCTION:
			case	SIGNED_64:
			case	ENUM:
			case	FUNCTION:
				tryMakeMode(operand, MC_FULL, 0, compileContext);
				return;

			case	CLASS:
				if (newType.indirectType(compileContext) != null) {
					tryMakeMode(operand, MC_FULL, 0, compileContext);
					return;
				}
				break;
			}
			break;

		case	ENUM:
			switch (newType.family()) {
			case	BOOLEAN:
			case	UNSIGNED_8:
			case	UNSIGNED_16:
			case	UNSIGNED_32:
			case	SIGNED_16:
			case	SIGNED_32:
			case	SIGNED_64:
			case	ENUM:
			case	FLOAT_32:
			case	FLOAT_64:
				markAddressModes(operand, compileContext);
				return;

			case	ADDRESS:
			case	FUNCTION:
				tryMakeMode(operand, MC_FULL, 0, compileContext);
				return;

			case	CLASS:
				if (newType.indirectType(compileContext) != null) {
					tryMakeMode(operand, MC_FULL, 0, compileContext);
					return;
				}
				break;
			}
			break;

		case	CLASS:
			if (existingType.indirectType(compileContext) != null) {
				switch (newType.family()) {
				case	SIGNED_32:
				case	SIGNED_64:
				case	ADDRESS:
				case	STRING:
				case	FUNCTION:
					tryMakeMode(operand, MC_FULL, 0, compileContext);
					return;
					
				case	CLASS:
					if (newType.indirectType(compileContext) != null) {
						tryMakeMode(operand, MC_FULL, 0, compileContext);
						return;
					}
					break;
				}
			} else {
				// A general class coercion from another class type.
				if (existingType.size() == newType.size())
					return;
			}
			break;
			
		case	FUNCTION:
			switch (newType.family()) {
			case	BOOLEAN:
			case	UNSIGNED_8:
			case	UNSIGNED_16:
			case	UNSIGNED_32:
			case	SIGNED_16:
			case	SIGNED_32:
			case	SIGNED_64:
			case	ENUM:
			case	ADDRESS:
			case	FUNCTION:
			case	FLOAT_32:
			case	FLOAT_64:
				markAddressModes(operand, compileContext);
				return;

			case	CLASS:
				if (newType.indirectType(compileContext) != null) {
					markAddressModes(operand, compileContext);
					return;
				}
				break;
			}
			break;
		}
		dest.print(0);
		assert(false);
	}
/*	
	void markMultiAssignLvalue(ref<Node> node, ref<CompileContext> compileContext) {
		if (node.op() == Operator.SEQUENCE) {
			ref<Binary> b = ref<Binary>(node);
			markMultiAssignLvalue(b.left(), compileContext);
			markAddressModes(b.right(), compileContext);
		} else
			markAddressModes(node, compileContext);
	}
*/
	void markConditionalAddressModes(ref<Node> node, ref<CompileContext> compileContext) {
		int modeComplexity = MC_FULL;
		int nClass = nodeClasses[node.op()];
		switch (node.op()) {
		case	LOGICAL_OR:
		case	LOGICAL_AND:
			ref<Binary> b = ref<Binary>(node);
			markConditionalAddressModes(b.left(), compileContext);
			markConditionalAddressModes(b.right(), compileContext);
			break;			
			
		case	NOT:
			ref<Unary> u = ref<Unary>(node);
			markConditionalAddressModes(u.operand(), compileContext);
			break;
			
		case	CALL:
		case	EQUALITY:
		case	GREATER:
		case	GREATER_EQUAL:
		case	LESS:
		case	LESS_EQUAL:
		case	LESS_GREATER:
		case	LESS_GREATER_EQUAL:
		case	NOT_EQUAL:
		case	NOT_GREATER:
		case	NOT_GREATER_EQUAL:
		case	NOT_LESS:
		case	NOT_LESS_EQUAL:
		case	NOT_LESS_GREATER:
		case	NOT_LESS_GREATER_EQUAL:
			markAddressModes(node, compileContext);
			break;

		case	DOT:
			tryMakeMode(node, MC_FULL, nClass, compileContext);
		case	IDENTIFIER:
			node.flags |= ADDRESS_MODE;
			break;
			
		default:
			node.print(0);
			assert(false);
		}
	}
	
	private int tryMakeMode(ref<Node> node, int modeContext, int nClass, ref<CompileContext> compileContext) {
		if	(node == null)
			return MC_FULL;
		if	(node.deferGeneration())
			return MC_FULL;
		switch	(node.op()){
/*
		case	O_ADR:
			if	(!isCompileTimeConstant(t))
				return MC_FULL;

		case	O_LITERAL:
		*/
		case	INTEGER:
			if	((modeContext & MC_CONST) != 0 &&
				 (nClass & NC_IMMED) != 0) {
				ref<Constant> number = ref<Constant>(node);
				long value = number.foldInt(compileContext);
				if (value >= int.MIN_VALUE && value <= int.MAX_VALUE)
					node.flags |= ADDRESS_MODE;
			}
			return MC_FULL;
/*
		case	O_REG:
			if	(ref iden_x(t).adjust == nullReg)
				return MC_FULL;
			else if	(isSegReg(ref iden_x(t).adjust)){
				if	(modeContext & MC_SREG)
					t.addrMode = TRUE;
				t.reg = ref iden_x(t).adjust;
				return MC_REG|MC_ADDRESS;
				}
			else if	(modeContext & MC_REG){
				t.addrMode = TRUE;
				t.reg = ref iden_x(t).adjust;
				}
			return MC_FULL;
*/
		case	SUBSCRIPT:
			if	((modeContext & MC_ADDRESS) != 0) {
				ref<Binary> b = ref<Binary>(node);
				node.flags |= ADDRESS_MODE;

				markAddressModes(b.left(), compileContext);
				markAddressModes(b.right(), compileContext);
				return justRegs(modeContext)|MC_CONST;
			}
			markAddressModes(node, compileContext);
			break;
			
		case	INDIRECT:
			if	((modeContext & MC_ADDRESS) != 0) {
				node.flags |= ADDRESS_MODE;

				tryMakeIndirectMode(ref<Unary>(node).operand(), compileContext);
				return justRegs(modeContext)|MC_CONST;
			}
			markAddressModes(node, compileContext);
			break;
/*
		case	O_TOS:
			if	(modeContext & MC_ADDRESS){
				t.addrMode = TRUE;
				return justRegs(modeContext)|MC_CONST;
				}
			break;

		case	O_AUTO:
			v = ref auto_x(t).var;
			if	(t.dtype sizeOf() == 1)
				ref auto_x(t).var.flags |= VF_BYTEREG;
			if	(v.flags & VF_REG){
				t.reg = v.reg;
				if	(isSegReg(v.reg)){
					if	(modeContext & MC_SREG)
						t.addrMode = TRUE;
					return MC_REG|MC_ADDRESS;
					}
				if	(!isByteReg(v.reg)){
					if	(modeContext & MC_REG &&
						 t.dtype sizeOf() > 1)
						t.addrMode = TRUE;
					return MC_FULL;
					}
				if	(modeContext & MC_REG)
					t.addrMode = TRUE;
				return MC_FULL;
				}
			if	(modeContext & MC_ADDRESS){
				t.addrMode = TRUE;
				return justRegs(modeContext)|MC_CONST;
				}
			break;
*/
		case	DOT:
			ref<Selection> dot = ref<Selection>(node);
			if	((modeContext & MC_ADDRESS) != 0) {
				dot.flags |= ADDRESS_MODE;
				if (dot.indirect()) {
					markAddressModes(dot.left(), compileContext);
					break;
				} else
					return tryMakeMode(dot.left(), modeContext, nClass, compileContext);
			}
			markAddressModes(node, compileContext);
			break;
			
		case	VARIABLE:
		case	IDENTIFIER:
			if	((modeContext & MC_ADDRESS) != 0) {
				node.flags |= ADDRESS_MODE;
				return (modeContext & MC_REG) | MC_CONST;
			}
			break;
			
		case	SEQUENCE:
			ref<Binary> b = ref<Binary>(node);
			markAddressModes(b.left(), compileContext);
			tryMakeMode(b.right(), modeContext, nClass, compileContext);
			break;
			
		default:
			markAddressModes(node, compileContext);
		}
		return MC_REG;
	}

	void tryMakeIndirectMode(ref<Node> node, ref<CompileContext> compileContext) {
		if (node.deferGeneration())
			return;
		switch (node.op()) {
		case	DOT:
			ref<Selection> dot = ref<Selection>(node);
			if (dot.indirect())
				markAddressModes(dot, compileContext);
			else {
				tryMakeMode(dot.left(), MC_FULL, nodeClasses[Operator.DOT], compileContext);
//				printf("---\n");
//				dot.print(4);
			}
			return;
		
		case	THIS:
		case	SUPER:
			node.flags |= ADDRESS_MODE;
			return;
		
		case	IDENTIFIER:
		case	VARIABLE:
			return;
			
		case	ADD:
			ref<Binary> b = ref<Binary>(node);
			if	(isCompileTimeConstant(b.right())){
				tryMakeIndirectMode(b.left(), compileContext);
				b.right().flags |= ADDRESS_MODE;
				b.flags |= ADDRESS_MODE;
			} else if	(isCompileTimeConstant(b.left())){
				tryMakeIndirectMode(b.right(), compileContext);
				b.left().flags |= ADDRESS_MODE;
				b.flags |= ADDRESS_MODE;
	/*
			} else if (isIndexRegister(theRegisterOf(left))){
				left->addrMode = TRUE;
				left->reg = nullReg;
				t->addrMode = TRUE;
				t->reg = nullReg;
				markAddressModes(right);
				}
			else if	(isIndexRegister(theRegisterOf(right))){
				right->addrMode = TRUE;
				right->reg = nullReg;
				t->addrMode = TRUE;
				t->reg = nullReg;
				markAddressModes(left);
	*/
			} else {
				markAddressModes(b.right(), compileContext);
				markAddressModes(b.left(), compileContext);
			}
			break;
	
		case	CAST:
		case	INDIRECT:
		case	CALL:
		case	ADDRESS:
		case	ASSIGN:
			markAddressModes(node, compileContext);
			break;
			
		default:
			node.print(0);
			assert(false);
		}
		/*
		r:		RegisterMask;
		v:		ref variable;
		left:		ref tree_p;
		right:		ref tree_p;
	
		t->reg = nullReg;
		if	(t->dtype &&
			 t->dtype->topType == T_ERROR)
			return;
		switch	(t->operator){
		case	O_REG:
			if	(isIndexRegister(ref iden_x(t)->adjust)){
				t->addrMode = TRUE;
				t->reg = ref iden_x(t)->adjust;
				}
			return;
	
		case	O_AUTO:
			v = ref auto_x(t)->var;
			if	(v->flags & VF_REG == 0)
				return;
			if	(isIndexRegister(v->reg)){
				t->addrMode = TRUE;
				t->reg = v->reg;
				}
			return;
	
		case	O_ICON:
			t->addrMode = TRUE;
			return;
	
		case	O_ADD:
			left  = ref binary_x(t)->left;
			right = ref binary_x(t)->right;
			if	(isCompileTimeConstant(right)){
				tryMakeIndirectMode(left);
				right->addrMode = TRUE;
				right->reg = nullReg;
				t->addrMode = TRUE;
				t->reg = nullReg;
				}
			else if	(isCompileTimeConstant(left)){
				tryMakeIndirectMode(right);
				left->addrMode = TRUE;
				left->reg = nullReg;
				t->addrMode = TRUE;
				t->reg = nullReg;
				}
			else if	(isIndexRegister(theRegisterOf(left))){
				left->addrMode = TRUE;
				left->reg = nullReg;
				t->addrMode = TRUE;
				t->reg = nullReg;
				markAddressModes(right);
				}
			else if	(isIndexRegister(theRegisterOf(right))){
				right->addrMode = TRUE;
				right->reg = nullReg;
				t->addrMode = TRUE;
				t->reg = nullReg;
				markAddressModes(left);
				}
			else	{
				markAddressModes(right);
				markAddressModes(left);
				}
			break;
	
		default:
			markAddressModes(node);
			}
			*/
	}
}
