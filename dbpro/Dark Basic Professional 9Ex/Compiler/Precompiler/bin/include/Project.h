#ifndef _DBPC_PROJECT_H
#define _DBPC_PROJECT_H
#include "Source.h"
#include <hash_set>

/**
 * Represents the project being compiled.
 * All Source files and their individual Lines can be accessed through this interface.
 * 
 *													- Joel "Rudolpho" Sjöqvist 2016-09-22
 **/
namespace dbpc {
	class Project {
		private:
			// Internal storage
			BYTE pmem[228];

			// Project objects should not be created or released from here; this is handled by the compiler
			Project();
			Project(const Project&);
			~Project();
			Project& operator=(const Project&);
		public:
			/**
			 * Retrieves the number of Sources that make up this Project.
			 * These correspond to the source files included by the DBPro project and there will always be
			 * at least one.
			 * 
			 * @returns size_t		- The number of Sources included by this Project.
			 **/
			size_t GetNumSources() const;

			/**
			 * Retrieves the specified Source belonging to this Project.
			 * The Sources can be used to query the actual code contents of the project being compiled.
			 * 
			 * @param	size_t		id		- The Source to retrieve; must be between 0 and GetNumSources() - 1.
			 * @returns Source*		- The id:th Source associated with this Project.
			 **/
			Source* GetSource(size_t id) const;

			/**
			 * Retrieves the path name of the directory from where the source files being compiled were loaded.
			 * You can use this along with Source::GetFileName() to get the full file names of the source files.
			 * 
			 * @returns	string		- The root path of the source files that make up this Project.
			 **/
			const std::string& GetSourcePath() const;

			/**
			 * Adds a new Source at the end of the current source contents of this Project.
			 * This works identically to #include "file-name.dba" when used from DBPro and can be used to include
			 * entire source files at once, rather than adding source line-by-line.
			 * Take note that the added source will be preprocessed such that all of its own #include directives
			 * are resolved and any files included by that will also be added to the project being compiled. This 
			 * process is recursive. All comments and empty lines will also be stripped from the source, as well as 
			 * any extraneous whitespace sequences trimmed down to a single space.
			 * If the specified file (or any of it's own #include directives) has already been included in the
			 * project it will not be re-included by calling this member function.
			 * 
			 * @param	string		fileName		- The name of the DBA file to load and add to the source being compiled. 
			 *										  Should be relative to the CWD or an absolute path.
			 **/
			void AddSource(const std::string& fileName);
		};
}
#endif