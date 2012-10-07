module lang::dimitri::levels::l6::Syntax
extend lang::dimitri::levels::l5::Syntax;

keyword DimitriKeywords = "terminatedBefore" | "terminatedBy";

syntax FieldSpecifier = fieldTerminatedBy: "terminatedBy" ValueListSpecifier values FormatSpecifier* format
                      | fieldTerminatedBefore: "terminatedBefore" ValueListSpecifier values FormatSpecifier* format
                      | fieldTerminatedBy: "terminatedBy" Callback call FormatSpecifier* format
                      | fieldTerminatedBefore: "terminatedBefore" Callback call FormatSpecifier* format
                      ;