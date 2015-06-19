namespace parasol:x86_64;
/*
 * This file defines the facilities for allocating register temporaries and marshalling
 * spills as necessary.
 */
import parasol:compiler.Node;
import parasol:compiler.TypeFamily;

/*
 * X86-64 Register mnemonics.
 */
enum R {
	NO_REG,			// Special marker for empty register position.
	RAX,
	RBX,
	RCX,
	RDX,
	
	RSP,
	RBP,
	RSI,
	RDI,
	
	R8,
	R9,
	R10,
	R11,
	
	R12,
	R13,
	R14,
	R15,
	
	XMM0,
	XMM1,
	XMM2,
	XMM3,
	
	XMM4,
	XMM5,
	XMM6,
	XMM7,
	
	XMM8,
	XMM9,
	XMM10,
	XMM11,
	
	XMM12,
	XMM13,
	XMM14,
	XMM15,
	
	AH,
	
	MAX_REG
}

string[R] regNames;

regNames.resize(R.MAX_REG);
regNames[R.RAX] = "RAX";
regNames[R.RBX] = "RBX";
regNames[R.RCX] = "RCX";
regNames[R.RDX] = "RDX";

regNames[R.RSP] = "RSP";
regNames[R.RBP] = "RBP";
regNames[R.RSI] = "RSI";
regNames[R.RDI] = "RDI";

regNames[R.R8] = "R8";
regNames[R.R9] = "R9";
regNames[R.R10] = "R10";
regNames[R.R11] = "R11";

regNames[R.R12] = "R12";
regNames[R.R13] = "R13";
regNames[R.R14] = "R14";
regNames[R.R15] = "R15";

regNames[R.XMM0] = "XMM0";
regNames[R.XMM1] = "XMM1";
regNames[R.XMM2] = "XMM2";
regNames[R.XMM3] = "XMM3";
regNames[R.XMM4] = "XMM4";
regNames[R.XMM5] = "XMM5";
regNames[R.XMM6] = "XMM6";
regNames[R.XMM7] = "XMM7";

regNames[R.XMM8] = "XMM8";
regNames[R.XMM9] = "XMM9";
regNames[R.XMM10] = "XMM10";
regNames[R.XMM11] = "XMM11";
regNames[R.XMM12] = "XMM12";
regNames[R.XMM13] = "XMM13";
regNames[R.XMM14] = "XMM14";
regNames[R.XMM15] = "XMM15";

regNames[R.AH] = "AH";

long RAXmask = getRegMask(R.RAX);
long RBXmask = getRegMask(R.RBX);
long RCXmask = getRegMask(R.RCX);
long RDXmask = getRegMask(R.RDX);
long R8mask = getRegMask(R.R8);
long R9mask = getRegMask(R.R9); 
long R10mask = getRegMask(R.R10); 
long R11mask = getRegMask(R.R11); 

long xmm0mask = getRegMask(R.XMM0);
long xmm1mask = getRegMask(R.XMM1);
long xmm2mask = getRegMask(R.XMM2);
long xmm3mask = getRegMask(R.XMM3);
long xmm4mask = getRegMask(R.XMM4);
long xmm5mask = getRegMask(R.XMM5);

long longMask = RAXmask|RCXmask|RDXmask|R8mask|R9mask|R10mask|R11mask;			// RBP and RSP are reserved
long floatMask = xmm0mask|xmm1mask|xmm2mask|xmm3mask|xmm4mask|xmm5mask;

long callMask = longMask|floatMask;

long[TypeFamily] familyMasks;

familyMasks.resize(TypeFamily.MAX_TYPES);
familyMasks[TypeFamily.SIGNED_8] = longMask;
familyMasks[TypeFamily.SIGNED_16] = longMask;
familyMasks[TypeFamily.SIGNED_32] = longMask;
familyMasks[TypeFamily.SIGNED_64] = longMask;
familyMasks[TypeFamily.UNSIGNED_8] = longMask;
familyMasks[TypeFamily.UNSIGNED_16] = longMask;
familyMasks[TypeFamily.UNSIGNED_32] = longMask;
familyMasks[TypeFamily.UNSIGNED_64] = longMask;
familyMasks[TypeFamily.ADDRESS] = longMask;
familyMasks[TypeFamily.TYPEDEF] = longMask;
familyMasks[TypeFamily.CLASS] = longMask;
familyMasks[TypeFamily.BOOLEAN] = longMask;
familyMasks[TypeFamily.FUNCTION] = longMask;
familyMasks[TypeFamily.STRING] = longMask;
familyMasks[TypeFamily.ENUM] = longMask;
familyMasks[TypeFamily.FLOAT_32] = floatMask;
familyMasks[TypeFamily.FLOAT_64] = floatMask;

/*
 * TempStack represents the state of temporary register allocation at any given moment.
 * The array can grow arbitrarily deep, because functions may be generated recursively
 * to an arbitrary depth and there is no promise that a given expression is the only
 * code pending full generation.
 * 
 * The RegisterState object is created for each function instance.  Within a function,
 * the allocation of machine registers to expression values is done one expression at a
 * time and all registers that are used in an expression and available to another expression.
 * 
 * Essentailly, all temporaries within an expression have properly nested lifetimes.
 * Even if the same register is used, the inputs to an expression are separate temporaries 
 * from the output of an expression.
 * 
 * As each operand of an expression is computed, it produces a computed value, which
 * is represented by a Temporary.  Temporaries begin life in a register, then move to
 * the stack and possibly back to a register as circumstances require.
 * 
 * The algorithm is in general as follows:
 * 
 *    As the parse tree is descended, through the set of generate calls, key points are 
 *    reached, such as EXPRESSION nodes that encompass a single expression.  At these 
 *    points, all temporary variables must be freed.  New ones will be allocated within the
 *    duration of the expression being computed and then they will be freed.
 *
 *    First, the costliest operand has temps assigned, then the cheapest.
 *    
 *    Second, the lifetime of the operand temporaries are terminated (using the clear method).
 *    
 *    The output register, if any, is assigned.
 *    
 *    Finally, a new temporary is constructed and the push method is used to start iy's lifetime. 
 */
class RegisterState {
	ref<TempStack> _t;
	int _tempBase;
	int _oldestUnspilled;
	long _freeRegisters;
	long _usedRegisters;
	
	// This variable is used during the cleanupOperands code, but must be shared with another function.
	
	long _tempRegisters;
	
	ref<Spill> _spills;
	ref<Spill> _lastSpill;
	
	public RegisterState(ref<TempStack> t) {
		_t = t;
		_tempBase = t.stackDepth();
		_oldestUnspilled = _tempBase;
		_freeRegisters = longMask|floatMask;
	}
	
	void makeTemp(ref<Node> n, R actual, long des) {
		long rNeg;

		if (des == 1)
			n.print(0);
		assert(des != 1);
		rNeg = getRegMask(actual);
		consumeRegs(rNeg);
		_t.makeTemp(n, actual, des);
	}
	/*
	 * This method first does a mop up to get the temporaries into proper registers, then releases
	 * all of them.
	 */
	void cleanupTemps(ref<Node> node, int stackDepth) {
		cleanupOperands(node, stackDepth);

		// Now free up the spare registers.
		
		while (stackDepth < _t.stackDepth()) {
			ref<Temporary> tm = _t.pop();
			long regMask = getRegMask(tm.currentReg);
			_freeRegisters |= regMask;
			_usedRegisters &= ~regMask;
			assert((_usedRegisters & _freeRegisters) == 0);
		}
		if (_oldestUnspilled > _t.stackDepth())
			_oldestUnspilled = _t.stackDepth();
	}
	/*
		tempCount will have the number of temps that must be cleaned up
		in the instruction.

		doesFit is the count of temps that fit in their respective operands.

		anyPushed is the count of temps on the stack.

		The _tempRegisters is a mask of the registers currently containing the
		temps (if any are in registers).
	 */
	void cleanupOperands(ref<Node> node, int stackDepth) {
		ref<Temporary> tm;
		boolean didAnything;

		int tempCount = _t.stackDepth() - stackDepth;

		// No temps at all, a not uncommon situation,
		// implies we do nothing.

		if	(tempCount == 0)
			return;

		int doesFit = 0;
		_tempRegisters = 0;
		int anyPushed = 0;

		for (int i = stackDepth; i < _t.stackDepth(); i++) {
			tm = _t.getTemp(i);
			if (tm.currentReg == R.NO_REG)
				anyPushed++;
			else {
				if	(fits(tm.currentReg, tm.desired))
					doesFit++;
				_tempRegisters |= getRegMask(tm.currentReg);
			}
		}

		// All the temps fit their needed allowed sets.  Here
		//   we only need to post any multiply referenced temps.

		if	(doesFit == tempCount)
			return;

		// We have exactly one temp, no effort required.  We just
		// clean it up.

		else if	(tempCount == 1) {
			tm.currentReg = cleanupTemp(node, tm);
			return;
		}

			/* If not all the temps are on the stack, we have to do some tricks to ensure that
			 * complicated situations don't get the wrong answer.  Note: the situation may not be taht
			 * bad, but these checks ensure that the messy situations are corrected before we do the
			 * simple stuff.
			 */

		if	(anyPushed < tempCount) {
			for	(;;) {

					/* First, clean up any temps that do not depend
					   on other temps being resolved.
					 */

				didAnything = false;
				for (int i = stackDepth; i < _t.stackDepth(); i++) {
					tm = _t.getTemp(i);

						/* If the temp is on the stack,
						   ignore it for now. */

					if	(tm.currentReg == R.NO_REG)
						continue;
					if	(!fits(tm.currentReg, tm.desired) &&
						 !overlaps(tm.desired, _tempRegisters)){
						tm.currentReg = cleanupTemp(node, tm);
						tm.desired = getRegMask(tm.currentReg);
						doesFit++;
						didAnything = true;
					}
				}

				if	(doesFit == tempCount - anyPushed)
					break;

				if	(didAnything)
					continue;

					/* If exactly two temps can be resolved by an
					   exchange, do it and stop.
					 */

				for (int i = stackDepth; i < _t.stackDepth(); i++) {
					tm = _t.getTemp(i);
					ref<Temporary> tp1;
					if	(fits(tm.currentReg, tm.desired))
						continue;
					for (int j = stackDepth; j < _t.stackDepth(); j++) {
						tp1 = _t.getTemp(j);
						if	(fits(tm.currentReg, tp1.desired))
							break;
					}
					if	(tp1 != null) {
						makeSpill(SpillKinds.XCHG, node, tp1.currentReg,
							tm.node, tp1.node);
						R xchg = tp1.currentReg;
						tp1.currentReg = tm.currentReg;
						tm.currentReg = xchg;
						doesFit++;
						if	(fits(tp1.currentReg, tp1.desired) &&
							 !fits(tm.currentReg, tp1.desired))
							doesFit++;
					} else {
						node.print(0);
						print();
						assert(false);
					}
					break;
				}
				if	(doesFit == tempCount - anyPushed)
					break;
			}
		}

			/* Now clean up the stack. */

		for (int i = _t.stackDepth() - 1; i >= stackDepth; i--) {
			tm = _t.getTemp(i);
			tm.currentReg = cleanupTemp(node, tm);
		}
	}
	/*
	 * This method 'cleans up' a temporary.  If it is on the stack or otherwise not in the correct
	 * register, get it into a satisfactory register.
	 */
	R cleanupTemp(ref<Node> node, ref<Temporary> tm) {
//		int allowedClass;
		long rx;
		R r, rnew;

			/* The temp may be on the stack */

		if	(tm.currentReg == R.NO_REG){
			rx = tm.desired;
			if	((rx & _freeRegisters) != 0)
				r = getreg(node, rx, rx);
			else {
				print();
				assert(false);
			}
			makeSpill(SpillKinds.POP, node, r, tm.node, null);
			consumeRegs(getRegMask(r));
		}

			/* Check for the possibility that the temp
			   is not in the right register.
			 */

		r = latestResult(tm.node);
		if	(r == R.NO_REG)
			return r;

			/*
			   This says that if the register is not where
			   we want it and also not where we can use it,
			   spill a temp.
			 */

		if	(!fits(r, tm.desired)) {
			rnew = getreg(node, tm.desired, tm.desired);
			makeSpill(SpillKinds.MOVE, node, rnew, tm.node, null);
			freeRegs(getRegMask(r));
			consumeRegs(getRegMask(rnew));
			_tempRegisters &= ~getRegMask(r);
			_tempRegisters |= getRegMask(rnew);
			r = rnew;
		}
		return r;
	}
	
	void generateSpills(ref<Node> tree, ref<X86_64Encoder> target) {
		if (_spills == null)
			return;
		if (target.verbose()) {
			printf("generateSpills %p\n", tree);
			print();
			tree.print(4);
		}
		for (;;) {
			if (tree != _spills.where)
				return;
			switch (_spills.spillKind) {
			case	PUSH:
				target.inst(X86.PUSH, TypeFamily.SIGNED_64, R(int(_spills.affected.register)));
				_spills.affected.register = 0;
				break;

			case	MOVE:
				switch (_spills.affected.type.family()) {
				case	UNSIGNED_8:
				case	UNSIGNED_16:
				case	SIGNED_32:
				case	SIGNED_64:
				case	STRING:
				case	ENUM:
				case	ADDRESS:
				case	CLASS:
				case	BOOLEAN:
					target.inst(X86.MOV, _spills.affected.type.family(), _spills.newRegister, R(int(_spills.affected.register)));
					break;
					
				case	FLOAT_32:
					target.inst(X86.MOVSS, _spills.affected.type.family(), _spills.newRegister, R(int(_spills.affected.register)));
					break;
					
				case	FLOAT_64:
					target.inst(X86.MOVSD, _spills.affected.type.family(), _spills.newRegister, R(int(_spills.affected.register)));
					break;
					
				default:
					_spills.print();
					printf("Moving: ");
					_spills.affected.type.print();
					printf("\n");
					assert(false);
				}
				_spills.affected.register = byte(int(_spills.newRegister));
				break;
				
			case	POP:
				target.inst(X86.POP, TypeFamily.SIGNED_64, _spills.newRegister);
				_spills.affected.register = byte(int(_spills.newRegister));
				break;
				
			case	XCHG:
				target.inst(X86.XCHG, TypeFamily.ADDRESS, R(int(_spills.affected.register)), R(int(_spills.other.register)));
				byte reg = _spills.affected.register;
				_spills.affected.register = _spills.other.register;
				_spills.other.register = reg;
				break;
				
			default:
				printf("generating:");
				_spills.print();
				_spills.affected.print(4);
				assert(false);
			}
			_spills = _spills.next;
			if (_spills == null) {
				_lastSpill = null;
				return;
			}
		}
	}
	
	void clobberSomeRegisters(ref<Node> tree, long regMask) {
		while ((_freeRegisters & regMask) != regMask)
			spillOldest(tree);
	}

	private void consumeRegs(long regMask) {
//		printf("consumeRegs(%x)\n", regMask);
		_freeRegisters &= ~regMask;			// Reserve the register
		_usedRegisters |= regMask;
		assert((_usedRegisters & _freeRegisters) == 0);
	}

	private void freeRegs(long regMask) {
		_freeRegisters |= regMask;
		_usedRegisters &= ~regMask;
		assert((_usedRegisters & _freeRegisters) == 0);
	}
	/*
	 * Transfer a register temp from its current location, to a register in
	 * the targetMask.  This happens when generating an operand could not
	 * put its output in the needed register set.
	 */
	void transfer(ref<Node> tree, ref<Node> affected, R dest) {
		long targetMask = getRegMask(dest);
		if (!overlaps(targetMask, _freeRegisters)) {
			assert(false);
		}
		getreg(tree, targetMask, targetMask);
		makeSpill(SpillKinds.MOVE, tree, dest, affected, null);
	}

	R getreg(ref<Node> tree, long required, long desired) {
		long r;

		while	((required & _freeRegisters) == 0) {
			if	(allSpilled()) {
				printf("\n\ngetreg(-, %x, %x)\n", required, desired);
				tree.print(4);
				print();
				assert(false);
			}
			spillOldest(tree);
		}
		if	((desired & required) != 0)
			desired &= required;
		if	((desired & _freeRegisters) != 0)
			r = desired & _freeRegisters;
		else
			r = required & _freeRegisters;
		return lowestReg(r);
	}

	void spillOldest(ref<Node> tree) {
		if (_oldestUnspilled < _t.stackDepth()) {
			ref<Temporary> tm = _t.getTemp(_oldestUnspilled);
			makeSpill(SpillKinds.PUSH, tree, R.NO_REG, tm.node, null);
			long regMask = getRegMask(tm.currentReg);
			_freeRegisters |= regMask;
			_usedRegisters &= ~regMask;
			assert((_usedRegisters & _freeRegisters) == 0);
			tm.currentReg = R.NO_REG;
			_oldestUnspilled++;
		} else {
			tree.print(4);
			print();
			assert(false);
		}
	}

	private void makeSpill(SpillKinds sKind, ref<Node> tree, R r, ref<Node> affected, ref<Node> other) {
		int i = affected.type.size();
		if	(sKind == SpillKinds.XCHG) {
			int j = other.type.size();
			if	(j > i)
				i = j;
		}
		ref<Spill> s = new Spill(_lastSpill, sKind, i, r, tree, affected, other);
		if	(_lastSpill != null)
			_lastSpill.next = s;
		else
			_spills = s;
		_lastSpill = s;
//		printf("--\n");
//		print();
	}

	boolean allSpilled() {
		return _oldestUnspilled >= _t.stackDepth();
	}

	/*
		latestResult

		This function is called when one is interested in the latest register
		that holds the temp.  Although it is unlikely,
		there is no reason why a given temp cannot be pushed, popped, moved
		and otherwise abused during the course of code generation.  As a
		result, to get the current register of a given temp, one must scan the
		spills for anything that affects the current node.

		Of course, should there be no related spills, then the register value
		itself is used.  The number of spills is typically very small.  Since
		many functions generate no spills at all, the whole for loop will be
		skipped.  When there are spills, more often than not the last spill
		will have been generated before the temp in question even came into
		existence, so the first iteration will fail.  In those rare
		circumstances when there are a bunch of recent spills then the loop
		must be executed several times, but these circumstances are the ones
		most likely to contain spills affecting the node being examined.
		
		Note: This method only applies while an expression tree is having registers
		allocated.  The process of code generation will reset the register value of
		tree nodes as spills are generated.
	 */
	R latestResult(ref<Node> node) {
		for (ref<Spill> s = _lastSpill; s != null; s = s.prev) {
			if (s.affected == node){
				assert(s.spillKind == SpillKinds.MOVE ||
					   s.spillKind == SpillKinds.XCHG ||
					   s.spillKind == SpillKinds.POP);
				if (s.spillKind == SpillKinds.XCHG) {
					node = s.other;
					continue;
				}
				assert(s.newRegister != R.NO_REG);
				return s.newRegister;
			} else if (s.spillKind == SpillKinds.XCHG && s.other == node)
				node = s.affected;
		}
		return R(node.register);
	}

	void print() {
		printf("used %x free %x\n", _usedRegisters, _freeRegisters);
		_t.print(_tempBase, _oldestUnspilled);
		if (_spills != null) {
			printf("Spills:\n");
			for (ref<Spill> s = _spills; s != null; s = s.next)
				s.print();
		}
	}
}

class TempStack {
	private ref<Temporary>[] _variableStack;
	private ref<Temporary>[] _freeTemps;
	
	ref<Temporary> tos() {
		if (_variableStack.length() == 0)
			return null;
		else
			return _variableStack[_variableStack.length() - 1];
	}
	
	void makeTemp(ref<Node> n, R r, long des) {
		ref<Temporary> tm;
		if (_freeTemps.length() == 0)
			tm = new Temporary(n, r, des);
		else {
			tm = _freeTemps.pop();
			tm.node = n;
			tm.reg = r;
			tm.currentReg = r;
			tm.desired = des;
		}
		_variableStack.push(tm);
	}
	
	ref<Temporary> getTemp(int i) {
		return _variableStack[i];
	}
	
	void push(ref<Temporary> v) {
		_variableStack.push(v);
	}
	
	ref<Temporary> pop() {
		return _variableStack.pop();
	}
	
	void free(ref<Temporary> tm) {
		_freeTemps.push(tm);
	}
	
	int stackDepth() {
		return _variableStack.length();			
	}

	void print(int start, int unspilled) {
		for (int i = start; i < _variableStack.length(); i++) {
			printf("%s[%d] ", i < unspilled ? "  spilled " : "unspilled ", i - start);
			_variableStack[i].print();
		}
	}
}
	
class Spill {
	public ref<Spill> next, prev;
	public SpillKinds spillKind;
	public byte width;		// spill width in bytes
	public R newRegister;
	public ref<Node> where, affected, other;
	public int tempVar;

	public Spill(ref<Spill> prv, SpillKinds sKind, int size, R reg, ref<Node> wh, ref<Node> aff, ref<Node> oth) {
		prev = prv;
		spillKind = sKind;
		width = byte(size);
		newRegister = reg;
		where = wh;
		affected = aff;
		other = oth;
	}
	
	public void print(ref<Node> tree) {
		for (ref<Spill> s = this; s != null; s = s.next)
			if	(s.where == tree)
				print();
	}
	
	public void print() {
		printf("    %p: spill %s w %d reg %s where %p\n", this, spillKindNames[spillKind], int(width), regNames[newRegister], where);
		affected.print(8);
	}
}


class Temporary {
	public ref<Node> node;
	R reg;
	R currentReg;
	long desired;
	
	Temporary(ref<Node> n, R r, long des) {
		node = n;
		reg = r;
		currentReg = r;
		desired = des;
	}
	
	void print() {
		printf("Temp %p reg %s currently %s desired %x\n", this, regNames[reg], regNames[currentReg], desired);
		if (node != null)
			node.print(4);
	}
}

enum SpillKinds {
	PUSH,
	POP,
	MOVE,
	XCHG,
	FPSPILL,	/* floating point spills use: spillKind, flags, */
	FPRELOAD	/* where, tempVar, newRegister			*/
}

string[SpillKinds] spillKindNames;

spillKindNames.append("PUSH");
spillKindNames.append("POP");
spillKindNames.append("MOVE");
spillKindNames.append("XCHG");
spillKindNames.append("FPSPILL");
spillKindNames.append("FPRELOAD");

R lowestReg(long regmask) {
	int r;

	assert(regmask != 0);
	r = 0;
	while ((regmask & 1) == 0) {
		regmask >>>= 1;
		r++;
	}
	return R(r);
}

long getRegMask(R rx) {
	return long(1) << int(rx);
}

/*
	This function returns a non-zero value if the named register is
	in the register mask given by res, zero otherwise.
 */
boolean fits(R reg, long res) {
	return (getRegMask(reg) & res) != 0;
}
/*
	This function returns non-zero if the two register masks share
	some common registers, zero otherwise.
 */
boolean overlaps(long rs1, long rs2) {
	return (rs1 & rs2) != 0;
}
