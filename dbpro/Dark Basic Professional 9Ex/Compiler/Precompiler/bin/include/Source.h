#ifndef _DBPC_SOURCE_H
#define _DBPC_SOURCE_H
#include "Line.h"
#include <string>
#include <WinDef.h>

/**
 * Represents a single source file within the project being compiled.
 * Any project will contain one or more source files, which in turn contains the Line instances
 * holding the actual source code.
 * A single Source instance corresponds directly to the (preprocessed contents of) an included
 * source file, including the "main" project source file.
 * 
 * Additional source files can be included during precompilation through the Project::AddSource()
 * function.
 *															- Joel "Rudolpho" Sjöqvist 2016-09-22
 **/
namespace dbpc {
	class Source {
		private:
			// Internal storage
			BYTE pmem[64];

			// Source objects should not be created or released from here; this is handled by the compiler
			Source();
			Source(const Source&);
			~Source();
			Source& operator=(const Source&);
		public:
			/**
			 * Retrieves the file name that this Source originates from, such as "main.dba" or "MyInclude.dba".
			 * 
			 * @returns	string		- The name of the source file that this Source's contents were loaded from.
			 **/
			const std::string& GetFileName() const;

			/**
			 * Retrieves the number of external source files included by this Source.
			 * Any such source files have been added to the parent Project instance that
			 * this Source instance belongs to.
			 * 
			 * @returns size_t		- The number of external source files included by this source. 
			 *						  Will return 0 for none.
			 **/
			size_t GetNumIncludes() const;

			/**
			 * Retrieves the file name of the specified external source file included by this Source.
			 * You can use this to find the corresponding Source instance through the parent Project.
			 * 
			 * @param	size_t		id		- The id of the included source to get the file name of. 
			 *								  Must be between 0 and GetNumIncludes() - 1.
			 * @returns string		- The file name of the id:th external source file included by this Source.
			 **/
			const std::string& GetIncludeName(size_t id) const;

			// NOTE: This has a time complexity of O(n) so shouldn't be used often!
			/**
			 * Gets the total number of available lines in this Source.
			 * This is the current number of Line instances associated with it, rather than the original file's line count
			 * (which can be retrieved using the GetOriginalLineCount() member function).
			 * Take note that this number is recalculated on each invocation meaning that you shouldn't call this function
			 * often for efficiency's sake; it has a linear time complexity to the number of lines.
			 * 
			 * @returns size_t		- The number of Lines belonging to this Source at the time of invocation.
			 **/
			size_t GetNumLines() const;

			/**
			 * Retrieves the first Line of this Source, assuming it has any.
			 * Use the GetNext() member function of the returned Line instance to iterate over all Lines belonging to
			 * this Source in sequence.
			 * 
			 * @returns Line*		- A pointer to the first Line in this Source, or «null» if all such Lines have 
			 *						  been removed.
			 **/
			Line* GetFirstLine();

			/**
			 * Removes the specified Line from this Source.
			 * 
			 * @param	Line*		pLine	- The line to remove from this Source.
			 **/
			void RemoveLine(Line *pLine);
			
			/**
			 * Retrieves the original line count of this Source, that is the number of lines in the file it was loaded from
			 * before any precomopilation took place. This includes comments, empty lines and #include directives that have
			 * been stripped from the Source presented here.
			 *
			 * @returns size_t		- The number of lines in the source file before precompilation.
			 **/
			size_t GetOriginalLineCount() const;
	};
}
#endif