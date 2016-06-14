UsnJrnlCarver

This is a simple tool to dump individual Usn pages (from UsnJrnl). Input must be a file, maybe an extract from unallocated.

Syntax is:
UsnJrnlCarver.exe /InputFile: /OutputPath:

Examples
UsnJrnlCarver.exe /InputFile:c:\unallocated.bin
UsnJrnlCarver.exe /InputFile:d:\unallocated.bin /OutputPath:d:\temp\out

If no input file is given as parameter, a fileopen dialog is launched. OutputPath is optional and resolves to program directory if omitted. Output looks like this:
Carver_UsnJrnl_2016-06-15_00-48-52.bin


This tool is handy when you have no means of accessing a healthy UsnJrnl. Unallocated chunks may contain numerous UsnPages/Usnjrnl records and that can be easily extracted. 

Warning
Running the tool against slack extract may not work very well as the concepts of sectors and clusters may not be preserved.

The final extract, is best parsed with tool UsnJrnl2Csv tool.


Changelog:

1.0.0.1:
Syntax change for commandline.
Added OutputPath as parameter.
Changed output names to Carver_UsnJrnl_<timestamp>.bin and Carver_UsnJrnl_<timestamp>.log

1.0.0.0:
First version
