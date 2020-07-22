IMPORT Std;
IMPORT $.Paths;

// Create the superfiles for all three levels
Std.File.CreateSuperFile(Paths.InputLevel1, , TRUE);
Std.File.CreateSuperFile(Paths.InputLevel2, , TRUE);
Std.File.CreateSuperFile(Paths.InputLevel2, , TRUE);
Std.File.ClearSuperFile(Paths.InputLevel1);
Std.File.ClearSuperFile(Paths.InputLevel2);
Std.File.ClearSuperFile(Paths.InputLevel3);
// Add 3 levels of Johns Hopkins Files
Std.File.AddSuperfile(Paths.InputLevel1, Paths.JHLevel1);
Std.File.AddSuperfile(Paths.InputLevel2, Paths.JHLevel2);
Std.File.AddSuperfile(Paths.InputLevel3, Paths.JHLevel3);
// Add Other Input Source Initializations here ...
