UsnJrnlCarver

This is a simple tool to dump individual Usn pages (from UsnJrnl). Input must be a file, maybe an extract from unallocated.

Syntax is:
UsnJrnlCarver.exe InputFile

Example 1
UsnJrnlCarver.exe c:\unallocated.bin

If no input file is given as parameter, a fileopen dialog is launched. Output is automatically resolved based on the input name. Output looks like this:
unallocated.bin.2015-02-14_21-46-54.UsnJrnl


This tool is handy when you have no means of accessing a healthy UsnJrnl. Unallocated chunks may contain numerous UsnPages/Usnjrnl records and that can be easily extracted. 

Warning
Running the tool against slack extract may not work very well as the concepts of sectors and clusters may not be preserved.

The final extract, is best parsed with tool UsnJrnl2Csv tool.


Changelog:

1.0.0.0:
First version
