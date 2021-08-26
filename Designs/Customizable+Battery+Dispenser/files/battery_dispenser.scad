// Customizable battery dispenser
//
// Generates a wall-mounted battery storage and dispenser device.
// The batteries this dispenser will work with can be customized as well as many
// other aspects.
//
// Share and enjoy!
//
// 27 Mar 2021 - Brad Kartchner - V 1.0

/* [Basic Parameters] */
// A list of the batteries to generate for ("AAA", "AA", "C", "D", and "9V")
Battery_List = ["AAA", "AAA", "AAA", "AA", "AA", "AA", "9V", "9V"];

// The height of the holder
Holder_Height = 147.01;

// The diameter of the shafts of the screws used to secure the battery holder to the wall (0 for no screws)
Screw_Shaft_Diameter = 5.01;

// The diameter of the heads of the screws used to secure the battery holder to the wall (0 for no screws)
Screw_Head_Diameter = 9.38;

/* [Advanced Parameters] */
// The name font
Name_Font = "Courier 10 Pitch:style=Bold";

// The height of the name plaques at the top of each column (0 for no plaque)
Name_Plaque_Height = 3.501;

// The amount to inset the name text
Name_Inset = 0.201;

// The thickness of the walls in the model
Wall_Thickness = 1.601;

// Extra padding spacing to ensure the batteries slide down the tubes nicely
Slide_Space = 0.161;

// Generate reference models for the batteries (true or false)?
Generate_Reference_Hardware = true;

// The quality to generate the model at ("draft" is faster but "final" looks better)
Quality = "final"; // ["draft", "final"]



include<battery_library.scad>



module Generate()
{
    // Generate the first battery column
    Generate_BatteryColumn(Battery_List[0]);

    // Generate the remaining battery columns
    if (len(Battery_List) > 1)
    {
        for (i = [1: len(Battery_List) - 1])
        {
            // Calculate the x-axis position of this column
            widths = [ for (j = [0: i-1]) ColumnOuterWidth(Battery_List[j]) - Wall_Thickness ];
            x_offset = SumVector(widths);
            translate([x_offset, 0, 0])
                Generate_BatteryColumn(Battery_List[i]);
        }
    }

    if (Screw_Shaft_Diameter > 0 && Screw_Head_Diameter > 0)
    {
        GenerateScrewTabs();
    }
}



module Generate_BatteryColumn(battery_name)
{
    if (BatteryLib_Type(battery_name) == "tube")
    {
        Generate_TubeBatteryColumn(battery_name);
    }
    else if (BatteryLib_Type(battery_name) == "rectangle")
    {
        Generate_RectangleBatteryColumn(battery_name);
    }

    if (Generate_Reference_Hardware)
    {
        x_offset = ColumnOuterWidth(battery_name)/2;
        y_offset = BatteryLib_Height(battery_name) + Wall_Thickness;
        z_bottom = BatteryLib_Width(battery_name)/2 + Wall_Thickness;
        for (z_offset = [0: BatteryLib_Width(battery_name) : Holder_Height - BatteryLib_Width(battery_name)])
        {
            translate([x_offset, y_offset, z_bottom + z_offset])
            rotate([90, 90, 0])
                %BatteryLib_GenerateBattery(battery_name);
        }
    }
}



module Generate_TubeBatteryColumn(battery_name)
{
    difference()
    {
        // Create a solid column to carve out
        column_width = ColumnOuterWidth(battery_name);
        column_depth = Holder_Depth;
        column_height = Holder_Height;
        cube([column_width, column_depth, column_height]);

        // Hollow out the column to make space for the batteries
        hollow_width = column_width - Wall_Thickness*2;
        hollow_depth = BatteryLib_Height(battery_name) + Slide_Space*2;
        hollow_height = column_height;
        hollow_x_offset = Wall_Thickness;
        hollow_y_offset = Wall_Thickness;
        hollow_z_offset = Wall_Thickness;
        translate([hollow_x_offset, hollow_y_offset, hollow_z_offset + hollow_width/2])
        {
            cube([hollow_width, hollow_depth, hollow_height]);

            // Round the bottom of the hollow space
            // This also cuts out the opening for the bottom-most battery to be removed
            translate([hollow_width/2, -Wall_Thickness - iota, 0])
            rotate([-90, 0, 0])
                cylinder(d=hollow_width, hollow_depth + Wall_Thickness + iota);
        }

        // Cut out a slot running down the front of the column
        slot_width = BatteryLib_AnodeDiameter(battery_name) + Slide_Space*2;
        slot_height = column_height - Wall_Thickness*4 - Name_Plaque_Height;
        slot_depth = Wall_Thickness + iota*2;
        slot_x_offset = column_width/2 - slot_width/2;
        slot_y_offset = -iota;
        slot_z_offset = Wall_Thickness;
        translate([slot_x_offset, slot_y_offset, slot_z_offset])
        {
            cube([slot_width, slot_depth, slot_height - slot_width/2]);

            // Round the top of the slot
            translate([slot_width/2, 0, slot_height - slot_width/2])
            rotate([-90, 0, 0])
                cylinder(d=slot_width, Wall_Thickness + iota*2);
        }

        // Create an access opening at the bottom front of the column
        access_width = hollow_width;
        access_depth = column_depth/3;
        access_height = Wall_Thickness + iota*2 + hollow_width/2;
        access_x_offset = Wall_Thickness;
        access_y_offset = -iota;
        access_z_offset = -iota;
        translate([access_x_offset, access_y_offset, access_z_offset])
        {
            cube([access_width, access_depth - access_width/2, access_height]);

            // Round the back end of the access opening
            translate([access_width/2, access_depth - access_width/2, 0])
                cylinder(d=access_width, access_height);
        }

        // Generate the name plaque at the top of the column
        if (Name_Plaque_Height > 0)
        {
            name_x_offset = column_width/2;
            name_y_offset = Name_Inset;
            name_z_offset = column_height - Wall_Thickness - Name_Plaque_Height/2;
            translate([name_x_offset, name_y_offset, name_z_offset])
            rotate([90, 0, 0])
            linear_extrude(Name_Inset + iota)
            resize([0, Name_Plaque_Height, 0], auto=true)
                text(battery_name, 10, Name_Font, halign="center", valign="center");
        }
    }
}



module Generate_RectangleBatteryColumn(battery_name)
{
    difference()
    {
        // Create a solid column to carve out
        column_width = ColumnOuterWidth(battery_name);
        column_depth = Holder_Depth;
        column_height = Holder_Height;
        cube([column_width, column_depth, column_height]);

        // Hollow out the column to make space for the batteries
        hollow_width = column_width - Wall_Thickness*2;
        hollow_depth = BatteryLib_Height(battery_name) + Slide_Space*2;
        hollow_height = column_height;
        hollow_x_offset = Wall_Thickness;
        hollow_y_offset = Wall_Thickness;
        hollow_z_offset = Wall_Thickness;
        translate([hollow_x_offset, hollow_y_offset, hollow_z_offset])
            cube([hollow_width, hollow_depth, hollow_height]);

        // Cut out the opening for the bottom-most battery to be removed
        opening_width = BatteryLib_BodyLength(battery_name) + Slide_Space*2;
        opening_depth = Wall_Thickness + iota*2;
        opening_height = BatteryLib_BodyWidth(battery_name) + Slide_Space*2;
        opening_x_offset = Wall_Thickness;
        opening_y_offset = -iota;
        opening_z_offset = Wall_Thickness;
        translate([opening_x_offset, opening_y_offset, opening_z_offset])
        {
            cube([opening_width, opening_depth, opening_height]);

            // Round the top of the opening
            translate([opening_width/2, 0, opening_height])
            rotate([-90, 0, 0])
                cylinder(d=opening_width, opening_depth);
        }

        // Cut out a slot running down the front of the column
        slot_width = max(BatteryLib_AnodeDiameter(battery_name), BatteryLib_CathodeDiameter(battery_name)) + Slide_Space*2;
        slot_height = column_height - Wall_Thickness*4 - Name_Plaque_Height;
        slot_depth = Wall_Thickness + iota*2;
        slot_x_offset = column_width/2 - slot_width/2;
        slot_y_offset = -iota;
        slot_z_offset = Wall_Thickness;
        translate([slot_x_offset, slot_y_offset, slot_z_offset])
        {
            cube([slot_width, slot_depth, slot_height - slot_width/2]);

            // Round the top of the slot
            translate([slot_width/2, 0, slot_height - slot_width/2])
            rotate([-90, 0, 0])
                cylinder(d=slot_width, Wall_Thickness + iota*2);
        }

        // Create an access opening at the bottom front of the column
        access_width = hollow_width;
        access_depth = column_depth/3;
        access_height = Wall_Thickness + iota*2 + hollow_width/2;
        access_x_offset = Wall_Thickness;
        access_y_offset = -iota;
        access_z_offset = -iota;
        translate([access_x_offset, access_y_offset, access_z_offset])
        {
            cube([access_width, access_depth - access_width/2, access_height]);

            // Round the back end of the access opening
            translate([access_width/2, access_depth - access_width/2, 0])
                cylinder(d=access_width, access_height);
        }

        // Generate the name plaque at the top of the column
        if (Name_Plaque_Height > 0)
        {
            name_x_offset = column_width/2;
            name_y_offset = Name_Inset;
            name_z_offset = column_height - Wall_Thickness - Name_Plaque_Height/2;
            translate([name_x_offset, name_y_offset, name_z_offset])
            rotate([90, 0, 0])
            linear_extrude(Name_Inset + iota)
            resize([0, Name_Plaque_Height, 0], auto=true)
                text(battery_name, 10, Name_Font, halign="center", valign="center");
        }
    }
}



module GenerateScrewTabs()
{
    GenerateScrewTab();

    translate([Holder_Width, 0, 0])
    mirror([1, 0, 0])
        GenerateScrewTab();
}



module GenerateScrewTab()
{
    difference()
    {
        // Create the basic rectangular tab
        tab_width = Screw_Head_Diameter + Wall_Thickness*2 + Slide_Space*2;
        tab_height = Holder_Height;
        tab_depth = Wall_Thickness;
        tab_x_offset = -tab_width;
        tab_y_offset = Holder_Depth - Wall_Thickness;
        tab_z_offset = 0;
        translate([tab_x_offset, tab_y_offset, tab_z_offset])
            cube([tab_width, tab_depth, tab_height]);

        // Drill out the screw slots
        shaft_hole_diameter = Screw_Shaft_Diameter + Slide_Space*2;
        head_hole_diameter = Screw_Head_Diameter + Slide_Space*2;
        hole_depth = tab_depth + iota*2;
        hole_distance = shaft_hole_diameter*2;
        hole_x_offset = -tab_width/2;
        hole_y_offset = tab_y_offset - iota;
        for (hole_z_offset = [tab_width/2 + hole_distance, tab_height - tab_width/2])
        {
            translate([hole_x_offset, hole_y_offset, hole_z_offset])
            {
                // Create a hole wide enough for the screw shaft
                rotate([-90, 0, 0])
                    cylinder(d=shaft_hole_diameter, hole_depth);

                // Create a hole wide enough for the screw head
                translate([0, 0, -hole_distance])
                rotate([-90, 0, 0])
                    cylinder(d=head_hole_diameter, hole_depth);

                // Create a slot connecting the two holes
                translate([-shaft_hole_diameter/2, 0, -hole_distance])
                    cube([shaft_hole_diameter, hole_depth, hole_distance]);
            }
        }
    }
}



function ColumnOuterWidth(battery_name) =
    BatteryLib_BodyLength(battery_name) + Slide_Space*2 + Wall_Thickness*2;



function SumVector(v, i = 0) =
    (i < len(v) - 1) ?
        v[i] + SumVector(v, i + 1) :
        v[i];



$fn = Quality == "final" ? 128 : 32;
iota = 0.001;

BatteryLib_Heights = [for (battery_name = Battery_List) BatteryLib_Height(battery_name) ];
Holder_Depth = max(BatteryLib_Heights) + Wall_Thickness*2 + Slide_Space*2;
Column_Widths = [for (battery_name = Battery_List) ColumnOuterWidth(battery_name) ];
Holder_Width = SumVector(Column_Widths) - Wall_Thickness * (len(Battery_List) - 1);

Generate();
