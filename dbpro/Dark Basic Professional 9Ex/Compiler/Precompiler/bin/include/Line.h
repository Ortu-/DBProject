#ifndef _DBPC_LINE_H
#define _DBPC_LINE_H
#include <string>
#include <sstream>
#include <list>
#include <WinDef.h>

/**
 * Represents a single source code line.
 * Lines have textual contents and a line number. Take note that the line number refers to the line in the original
 * source (ie. before any precompilation takes place) that this text originates from. When inserting new lines 
 * through precompilation, these will be considered as originating from, and therefore have the same line numbers as, 
 * their parent lines.
 * If a Line's text is updated to contain any newline ('\n') characters, the text will be split and a sub-line will
 * be inserted for each such line break.
 * 
 *																			- Joel "Rudolpho" Sjöqvist 2016-09-22
 **/
namespace dbpc {
	class Line {
		private:
			// Internal storage
			BYTE pmem[80];

			// Line objects should not be created or released from here; this is handled by the compiler
			Line();
			Line(const Line&);
			~Line();
			Line& operator=(const Line&);
		public:
			/**
			 * Retrieves the text of this source line.
			 * Can optionally return a cached all-uppercase version for quicker searching for certain keywords.
			 * Take note that the returned string is read-only; use the SetText() member function to change it.
			 *
			 * @oparam	bool	useUppercase	- Set to «true» to return an all-uppercase version of this line's comments, or «false» to return it as-is. Default: false.
			 * @returns	string	- The text contents of this line, optionally in all uppercase.
			 **/
			const std::string& GetText(bool useUppercase = false) const;

			/**
			 * Retrieves the line number associated with this line in the original (input) source.
			 * This is what will be reported if there is an error on this line.
			 * As part of precompilation, multiple lines may be inserted that will still be considered to have the same line number; this can be thought of
			 * for example as a macro expansion, which may expand to cover multiple lines, but for debugging the programmer will want to know the line in the
			 * actual source code (ie. before any precompilation changes) where the macro occurs.
			 * The actual line ordering is determined by the previous and next settings of each individual line.
			 * Also take note that comments, #include statements and empty lines are removed as the first step of precompilation.
			 * As such there may be "missing" blank line numbers for lines that have been removed. This is perfectly normal.
			 *
			 * @returns size_t	- The line number associated with this line.
			 **/
			size_t GetLineNumber() const;

			/**
			 * Retrieves the previous line in the source file, if any exists.
			 *
			 * @returns Line*	- The Line preceeding this line in the source file, or «null» if there is no such line (ie. this is the first line).
			 **/
			Line* GetPrevious() const;

			/**
			 * Retrieves the next line in the source file, if any exists.
			 *
			 * @returns Line*	- The Line following this line in the source file, or «null» if there is no such line (ie. this is the last line).
			 **/
			Line* GetNext() const;

			/**
			 * Replaces the text of this line.
			 * If the new text contains any newline characters ('\n'), the string will be split and new Line instances that correspond to each
			 * such source line will be inserted following this Line. Each such line will have the same line number as this Line.
			 * You should not insert comments or #include directives as those have already been stripped at the start of precompilation and
			 * inserting new ones may confuse any other precompilation stages that will execute after this one. It will also slow down the
			 * compilation process to have to go through this again.
			 * Comments are useless at this point (the precompiled source will not normally be visible to the DBPro programmer) and if you
			 * want to include a different source file you should use Project::AddSource().
			 *
			 * @param	string	newContent		- The new text content to set for this line.
			 * @returns	Line*	- The last line that was inserted as a result of setting the provided line content. Will return «this» if the content string is single line.
			 **/
			Line* SetText(const std::string& newContent);

			/**
			 * Inserts a new Line with the given text content immediately before this Line.
			 *
			 * @param	string	content			- The text content of the line to insert.
			 * @returns Line*	- The newly inserted Line.
			 **/
			Line* InsertBefore(const std::string& content);

			/**
			 * Inserts a new Line with the given text content immediately following this Line.
			 *
			 * @param	string	content			- The text content of the line to insert.
			 * @returns Line*	- The newly inserted Line.
			 **/
			Line* InsertAfter(const std::string& content);
		};
}
#endif