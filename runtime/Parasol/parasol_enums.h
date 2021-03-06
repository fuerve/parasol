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
#ifndef PARASOL_HEADER_H
#define PARASOL_HEADER_H
enum SectionType {
	ST_ERROR,
	ST_SOURCE,
	ST_BYTE_CODES,
	ST_X86_64,
};
enum ByteCodes {
	B_ILLEGAL,
	B_INT,
	B_LONG,
	B_STRING,
	B_CALL,
	B_ICALL,
	B_VCALL,
	B_XCALL,
	B_LDTR,
	B_INVOKE,
	B_CHKSTK,
	B_SP,
	B_LOCALS,
	B_VARG,
	B_VARG1,
	B_POP,
	B_POPN,
	B_DUP,
	B_SWAP,
	B_RET,
	B_RET1,
	B_RETN,
	B_STSA,
	B_LDSA,
	B_STSB,
	B_LDSB,
	B_STSC,
	B_LDSC,
	B_STSI,
	B_LDSI,
	B_LDSU,
	B_STSO,
	B_STSS,
	B_LDSS,
	B_STAA,
	B_LDAA,
	B_STAB,
	B_LDAB,
	B_LDAC,
	B_STAI,
	B_LDAI,
	B_LDAU,
	B_LDAO,
	B_STAO,
	B_STAS,
	B_LDAS,
	B_STAV,
	B_STVA,
	B_STVB,
	B_STVI,
	B_STVO,
	B_STVS,
	B_STVV,
	B_LDPA,
	B_STPA,
	B_LDPB,
	B_STPB,
	B_LDPC,
	B_LDPI,
	B_LDPL,
	B_LDPU,
	B_STPI,
	B_STPL,
	B_LDPO,
	B_STPO,
	B_STPS,
	B_LDPS,
	B_LDIA,
	B_STIA,
	B_POPIA,
	B_LDIB,
	B_STIB,
	B_LDIC,
	B_STIC,
	B_LDII,
	B_STII,
	B_LDIL,
	B_STIL,
	B_LDIU,
	B_LDIO,
	B_STIO,
	B_LDIV,
	B_STIV,
	B_MUL,
	B_DIV,
	B_REM,
	B_ADD,
	B_SUB,
	B_LSH,
	B_RSH,
	B_URS,
	B_OR,
	B_AND,
	B_XOR,
	B_NOT,
	B_NEG,
	B_BCM,
	B_MULV,
	B_DIVV,
	B_REMV,
	B_ADDV,
	B_SUBV,
	B_LSHV,
	B_RSHV,
	B_URSV,
	B_ORV,
	B_ANDV,
	B_XORV,
	B_EQI,
	B_NEI,
	B_GTI,
	B_GEI,
	B_LTI,
	B_LEI,
	B_GTU,
	B_GEU,
	B_LTU,
	B_LEU,
	B_EQL,
	B_NEL,
	B_GTL,
	B_GEL,
	B_LTL,
	B_LEL,
	B_GTA,
	B_GEA,
	B_LTA,
	B_LEA,
	B_EQV,
	B_NEV,
	B_GTV,
	B_GEV,
	B_LTV,
	B_LEV,
	B_LGV,
	B_NGV,
	B_NGEV,
	B_NLV,
	B_NLEV,
	B_NLGV,
	B_CVTBI,
	B_CVTCI,
	B_CVTIL,
	B_CVTUL,
	B_CVTIV,
	B_CVTLV,
	B_CVTSV,
	B_CVTAV,
	B_CVTVI,
	B_CVTVS,
	B_CVTVA,
	B_SWITCHI,
	B_SWITCHE,
	B_JMP,
	B_JZ,
	B_JNZ,
	B_NEW,
	B_DELETE,
	B_THROW,
	B_ADDR,
	B_ZERO_A,
	B_ZERO_I,
	B_AUTO,
	B_AVARG,
	B_PARAMS,
	B_ASTRING,
	B_VALUE,
	B_CHAR_AT,
	B_CLASSV,
	B_string,
	B_MAX_BYTECODE,
};
#endif // PARASOL_HEADER_H
