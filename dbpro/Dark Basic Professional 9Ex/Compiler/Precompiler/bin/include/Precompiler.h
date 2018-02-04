#ifndef _DBPC_PRECOMPILER_H
#define _DBPC_PRECOMPILER_H
/**
 * Main include file for the DBPro precompiler library.
 * Includes all other required headers.
 *									- Joel "Rudolpho" Sjöqvist 2016-09-22
 **/
#include "Project.h"
#include "Source.h"
#include "Line.h"

/**
 * All precompiler-specific functionality is contained in the «dbpc» namespace (for
 * DarkBasic PreCompiler).
 **/
namespace dbpc { 
	/**
	 * Supplies compiler-specific data to the internal workings of the precompiler library.
	 * This function should be called from the ReceiveCompilerData() function, which should
	 * be exported and will be called by the compiler prior to calling the Precompile() function.
	 * Failing to call this function before Precompile() is invoked will result in crashes unless
	 * you only use the precompilation to read source data rather than change it.
	 * 
	 * @param	void*		pData		- The compiler-provided data necessary for correct function of Precompiler.lib
	 **/
	void SetInternalData(void *pData);
}

/**
 * Declaring these as extern here ensures that we get linker errors if they are not added to the project.
 * These functions *must* be exported by a valid precompiler library.
 **/
extern __declspec(dllexport) void ReceiveCompilerData(void *pData);
extern __declspec(dllexport) bool Precompile(dbpc::Project *pProject);
#endif