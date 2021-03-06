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
#ifndef PARASOL_RUNTIME_H
#define PARASOL_RUNTIME_H

#include "common/machine.h"
#include "parasol_enums.h"
#include "pxi.h"
#include "x86_pxi.h"

namespace parasol {

const int INDENT = 4;

const int BYTE_CODE_TARGET = 1;
const int NATIVE_64_TARGET = 2;

typedef long long WORD;

#define STACK_SLOT (sizeof (WORD))
#define FRAME_SIZE (sizeof(WORD) + 2 * sizeof(void*))

static const int STACK_SIZE = STACK_SLOT * 256 * 1024;

class Code;
class ExceptionContext;
class Type;

struct StackFrame {
	byte *fp;
	byte *code;
	int ip;
};

struct StackState {
	byte *sp;
	byte *stack;
	byte *stackTop;
	StackFrame frame;
	int target;
	int exceptionType;
	int exceptionFlags;
	void *memoryAddress;			// Valid only for memory exceptions
};

class ExecutionContext {
public:
	ExecutionContext(void **objects, int objectCount);

	ExecutionContext(X86_64SectionHeader *pxiHeader, void *image);

	~ExecutionContext();

	void enter();

	ExceptionContext *exceptionContext(ExceptionContext *exceptionInfo);

	bool push(char **argv, int argc);

	bool push(void *pointerValue);

	bool push(WORD intValue);

	WORD pop();

	WORD peek();

	WORD st(int index);

	void *popAddress();

	void *peekAddress();

	StackState unloadFrame();

	bool run(int objectId);

	int runNative(int (*start)(void *args));

	void reloadFrame(const StackState &saved);

	void snapshot(byte *highestSp);

	void transferSnapshot(ExecutionContext *source);

	void fetchSnapshot(byte *output, int length);

	int injectObjects(void **objects, int objectCount);

	void throwException(const StackState &state);

	void halt();

	void *valueAddress(int i);

	int valueIndex(void *address);

	void print();

	int target() { return _target; }

	int ip() { return _active.ip; }

	byte *fp() { return _active.fp; }

	byte *sp() { return _sp; }

	byte *stack() { return _stack; }

	byte *code() { return _active.code; }

	int lastIp() { return _lastIp; }

	void **objects() { return _objects; }

	int objectCount() { return _objectCount; }

	vector<string> &args() { return _args; }

	bool trace;
private:
	bool run();

//	void invoke(WORD methodName, WORD object);

	void invoke(byte *code);

	void disassemble(int ip);

	int intInByteCode() {
		int x = *(int*)(_active.code + _active.ip);
		_active.ip += sizeof (int);
		return x;
	}

	long long longInByteCode() {
		long long x = *(long long*)(_active.code + _active.ip);
		_active.ip += sizeof (long long);
		return x;
	}

	int _target;
	void **_objects;
	int _objectCount;
	byte *_stack;
	byte *_stackTop;
	int _length;
	StackFrame _active;
	byte *_sp;
	ExceptionContext *_exceptionContext;
	X86_64SectionHeader *_pxiHeader;
	void *_image;
	int _lastIp;
	vector<byte> _stackSnapshot;
	vector<string> _args;
};

// Exception table consist of some number of these entries, sorted by ascending location value.
// Any IP value between the location of one entry and the next is processed by the assicated handler.
// A handler value of 0 indicates no handler exists.
class ExceptionEntry {
public:
	int location;
	int handler;
};

class ExceptionTable {
public:
	int length;
	int capacity;
	ExceptionEntry *entries;
};

class ExceptionInfo {

};

class ExceptionContext {
public:
	void *exceptionAddress;		// The machine instruction causing the exception
	void *stackPointer;			// The thread stack point at the moment of the exception
	void *framePointer;			// The frame pointer at the moment of the exception

	// This is a copy of the hardware stack at the time of the exception.  It may extend beyond the actual
	// hardware stack at the moment of the exception because, for example, the call to create the copy used
	// the address of a local variable to get a stack offset.

	// To compute the address in the copy from a forensic machine address, use the following:
	//
	//	COPY_ADDRESS = STACK_ADDRESS - stackBase + stackCopy;

	void *stackBase;			// The machine address of the hardware stack this copy was taken from
	byte *stackCopy;			// The first byte of the copy
	void *memoryAddress;		// Valid only for memory exceptions: memory location referenced
	int exceptionType;			// Exception type
	int exceptionFlags;			// Flags (dependent on type).
	int stackSize;				// The length of the copy

	long long slot(void *stackAddress) {
		long long addr = (long long)stackAddress;
		long long base = (long long)stackBase;
		long long copy = (long long)stackCopy;
		long long target = addr - base + copy;
		long long *copyAddress = (long long*)target;
		return *copyAddress;
	}
};

WORD stackSlot(ExceptionContext *context, void *stackAddress);

class ByteCodeMap {
public:
	ByteCodeMap();

	static const char *name[B_MAX_BYTECODE];
};

enum VariantKind {
	K_EMPTY,			// No value at all, equals null
	K_INT,				// An integer value
	K_DOUBLE,			// A double value
	K_STRING,			// A string value
	K_OBJECT,			// An object value (pointer to object stored indirectly (not currently supported)
	K_REF				// A reference to an object (same bits as an object, but
						// no delete in the destructor
};

class Variant {
	friend class ExecutionContext;
public:
	Variant() {
		_kind = null;
	}

	~Variant() {
		clear();
	}

	Variant(const Variant& source) {
		init(source);
	}

	Variant(Type *kind, void *value) {
		_kind = kind;
		_value.pointer = value;
	}

	bool equals(Variant &other) const;

	const Variant& operator= (const Variant &source) {
		clear();
		init(source);
		return source;
	}

	void clear();

	Type *kind() const { return _kind; }

	long long asLong() const { return _value.integer; }

	double asDouble() const { return _value.floatingPoint; }

	void *asRef() const { return _value.pointer; }

	string *asString() { return (string*)&_value.pointer; }

	void setLong(long long x) { _value.integer = x; }

	void setAddress(void *a) { _value.pointer = a; }

private:
	Type *_kind;

	void init(const Variant& source);

	union {
		long long	integer;
		double		floatingPoint;
//		string		text;				C++ doesn't like this sort of type in a union.
		void		*pointer;
	} _value;

};
/*
	Reutrns non-null function name for valid index values, null for invalid values (< 0 or > maximum function).
 */
const char *builtInFunctionName(int index);

const char *builtInFunctionDomain(int index);

WORD (*builtInFunctionAddress(int index))();

int builtInFunctionArguments(int index);

int builtInFunctionReturns(int index);

class ByteCodeSectionHeader {
public:
	int entryPoint;				// Object id of the starting function to run in the image
	int objectCount;			// Total number of objects in the object table
	int relocationCount;		// Total number of relocations
private:
	int _1;
};

class ByteCodeRelocation {
public:
	int relocObject;			// Object id of the location of the relocation
	int relocOffset;			// Object offset of the location being relocated
	int reference;				// Object id of the relocation value
	int offset;					// Offset within the reference object of the relocation address
};

class ByteCodeSection : public pxi::Section {
	vector<void *> _objects;
	void *_image;
	int _entryPoint;

public:
	ByteCodeSection(FILE *pxiFile, long long length);

	~ByteCodeSection();

	virtual bool run(char **args, int *returnValue, bool trace);

	bool valid() {
		return _objects.size() > 0 && _image != null;
	}

private:
	void dumpIp(ExecutionContext *executionContext);

	void dumpStack(ExecutionContext *executionContext);

	string collectIp(ExecutionContext *executionContext, byte *code, int ip);

};

WORD (*builtInFunctionAddress(int index))();
int evalNative(X86_64SectionHeader *header, byte *image, char **argv, int argc);
void fetchSnapshot(byte *output, int length);
void *formatMessage(unsigned NTStatusMessage);
void indentBy(int indent);

}


#endif // PARASOL_RUNTIME_H
