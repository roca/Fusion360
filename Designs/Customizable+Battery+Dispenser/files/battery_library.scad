// Battery modeling library
//
// Simplifies (for me, anyway) generating models of and for common battery types.
//
// Share and enjoy!
//
// 27 Mar 2021 - Brad Kartchner - V 1.0
//  Supports "AAA", "AA", "C", "D", and "9V" batteries.
//  Could be easily extended (and probably should be) for coin cell batteries.

IDX_NAME = 0;
IDX_TYPE = IDX_NAME + 1;

// Tube battery dimensions
//
// |<-->| Body Diameter
//  >||<- Anode Diameter
//  _--_  === Anode Height
// |    |  ^
// |    |  |
// |    | Body Height
// |    |  |
// |____|  V
//   --   === Cathode Height
//  >||<- Cathode Diameter
IDX_TUBE_BODY_DIAMETER = IDX_TYPE + 1;
IDX_TUBE_BODY_HEIGHT = IDX_TUBE_BODY_DIAMETER + 1;
IDX_TUBE_CATHODE_DIAMETER = IDX_TUBE_BODY_HEIGHT + 1;
IDX_TUBE_CATHODE_HEIGHT = IDX_TUBE_CATHODE_DIAMETER + 1;
IDX_TUBE_ANODE_DIAMETER = IDX_TUBE_CATHODE_HEIGHT + 1;
IDX_TUBE_ANODE_HEIGHT = IDX_TUBE_ANODE_DIAMETER + 1;



// Rectangular battery Round_Battery_Dimensions
// ...well, really, just 9v batteries...
//
// Cathode Diameter
//  |
//  >||< >||<- Anode Diameter
//  _--___--_ ==== Terminal Height
// |         |  ^
// |         |  |
// |         | Body Height
// |         |  |
// |_________|  V
// |<------->|<- Body Width
//
//  __--__
// |      |
// |      |
// |      |
// |      |
// |______|
// |<---->|<- Body Length
IDX_RECT_BODY_WIDTH = IDX_TYPE + 1;
IDX_RECT_BODY_LENGTH = IDX_RECT_BODY_WIDTH + 1;
IDX_RECT_BODY_HEIGHT = IDX_RECT_BODY_LENGTH + 1;
IDX_RECT_CATHODE_DIAMETER = IDX_RECT_BODY_HEIGHT + 1;
IDX_RECT_CATHODE_HEIGHT = IDX_RECT_CATHODE_DIAMETER + 1;
IDX_RECT_ANODE_DIAMETER = IDX_RECT_CATHODE_HEIGHT + 1;
IDX_RECT_ANODE_HEIGHT = IDX_RECT_ANODE_DIAMETER + 1;
IDX_RECT_TERMINAL_DISTANCE = IDX_RECT_ANODE_HEIGHT + 1;



// These battery dimensions are based mostly on dimensions found in Wikipedia
// articles for each battery, along with some actual measurements.  They're
// accurate for the batteries I have, but may need some tweaking to account
// for variations between manufacturers.
BatteryLib_Dimensions =
[
    [
        "AAA",
        "tube",
        10.50,  // Body diameter
        43.50,  // Body height
         6.30,  // Cathode diameter
         0.40,  // Cathode height
         3.80,  // Anode diameter
         0.80,  // Anode height
    ],

    [
        "AA",
        "tube",
        14.50,  // Body diameter
        49.50,  // Body height
         9.10,  // Cathode diameter
         0.40,  // Cathode height
         5.50,  // Anode diameter
         1.00,  // Anode height
    ],

    [
        "C",
        "tube",
        26.20,  // Body diameter
        47.60,  // Body height
        18.00,  // Cathode diameter
         0.40,  // Cathode height
         6.00,  // Anode diameter
         2.00,  // Anode height
    ],

    [
        "D",
        "tube",
        34.20,  // Body diameter
        59.60,  // Body height
        18.00,  // Cathode diameter
         0.40,  // Cathode height
         9.50,  // Anode diameter
         1.50,  // Anode height
    ],

    [
        "9V",
        "rectangle",
        26.50,  // Body Width
        17.50,  // Body Length
        46.40,  // Body height
         8.52,  // Cathode diameter
         2.10,  // Cathode height
         5.75,  // Anode diameter
         2.10,  // Anode height
        12.70,  // terminal distance
    ],
];



// Generate a model of a specified battery
// Supported battery names
// ["AAA", "AA", "C", "D", "9V"]
module BatteryLib_GenerateBattery(battery_name)
{
    if (BatteryLib_Type(battery_name) == "tube")
        BatteryLib_GenerateTubeBattery(battery_name);
    else if (BatteryLib_Type(battery_name) == "rectangle")
        BatteryLib_GenerateRectangleBattery(battery_name);
    else
        assert(false, str(battery_name, " type ", BatteryLib_Type(battery_name), " is not a recognized battery type"));
}



// Generate a specified "tube" style battery
module BatteryLib_GenerateTubeBattery(battery_name)
{
    if (BatteryLib_Type(battery_name) != "tube")
        assert(false, str(battery_name, " is not a tube battery"));

    body_diameter = BatteryLib_BodyDiameter(battery_name);
    body_height = BatteryLib_BodyHeight(battery_name);
    cathode_diameter = BatteryLib_CathodeDiameter(battery_name);
    cathode_height = BatteryLib_CathodeHeight(battery_name);
    anode_diameter = BatteryLib_AnodeDiameter(battery_name);
    anode_height = BatteryLib_AnodeHeight(battery_name);

    translate([0, 0, cathode_height])
    {
        cylinder(d=body_diameter, body_height);
        translate([0, 0, body_height])
            cylinder(d=anode_diameter, anode_height);
        translate([0, 0, -cathode_height])
            cylinder(d=cathode_diameter, cathode_height);
    }
}



// Generate a specified "rectangle" battery
module BatteryLib_GenerateRectangleBattery(battery_name)
{
    if (BatteryLib_Type(battery_name) != "rectangle")
        assert(false, str(battery_name, " is not a rectangle battery"));

    body_width = BatteryLib_BodyWidth(battery_name);
    body_length = BatteryLib_BodyLength(battery_name);
    body_height = BatteryLib_BodyHeight(battery_name);
    cathode_diameter = BatteryLib_CathodeDiameter(battery_name);
    cathode_height = BatteryLib_CathodeHeight(battery_name);
    anode_diameter = BatteryLib_AnodeDiameter(battery_name);
    anode_height = BatteryLib_AnodeHeight(battery_name);
    terminal_distance = BatteryLib_TerminalDistance(battery_name);

    translate([-body_width/2, -body_length/2, 0])
        cube([body_width, body_length, body_height]);
    translate([-terminal_distance/2, 0, body_height])
        cylinder(d=anode_diameter, anode_height);
    translate([terminal_distance/2, 0, body_height])
        cylinder(d=cathode_diameter, cathode_height);
}


// Retrieve the parameters specific to a specified battery
function RetrieveBatteryParameters(battery_name) =
	BatteryLib_Dimensions [search([battery_name], BatteryLib_Dimensions) [0] ];

// Retrieve the type of a specified battery
function BatteryLib_Type(battery_name) =
    RetrieveBatteryParameters(battery_name) [IDX_TYPE];

// Retrieve the body diameter of a specified battery
// This really only applies to tube batteries
// For rectangle batteries, the larger of the width and length dimensions is
// returned
function BatteryLib_BodyDiameter(battery_name) =
    BatteryLib_Type(battery_name) == "tube" ?
        RetrieveBatteryParameters(battery_name) [IDX_TUBE_BODY_DIAMETER] :
        max(BatteryLib_BodyWidth(battery_name), BatteryLib_Length(battery_name));

// Retrieve the diameter of a specified battery
// This is just syntactic sugar for the previous function
function BatteryLib_Diameter(battery_name) =
    BatteryLib_BodyDiameter(battery_name);

// Retrieve the width of a specified battery
function BatteryLib_BodyWidth(battery_name) =
    BatteryLib_Type(battery_name) == "tube" ?
        RetrieveBatteryParameters(battery_name) [IDX_TUBE_BODY_DIAMETER] :
        RetrieveBatteryParameters(battery_name) [IDX_RECT_BODY_WIDTH];

// Retrieve the width of a specified battery
// This is just syntactic sugar for the previous function
function BatteryLib_Width(battery_name) =
    BatteryLib_BodyWidth(battery_name);

// Retrieve the length (in the y dimension) of a specified battery
function BatteryLib_BodyLength(battery_name) =
    BatteryLib_Type(battery_name) == "tube" ?
        RetrieveBatteryParameters(battery_name) [IDX_TUBE_BODY_DIAMETER] :
        RetrieveBatteryParameters(battery_name) [IDX_RECT_BODY_LENGTH];

// Retrieve the length of a specified battery
// This is just syntactic sugar for the previous function
function BatteryLib_Length(battery_name) =
    BatteryLib_BodyLength(battery_name);

// Retrieve the body height (in the z dimension) of a specified battery
function BatteryLib_BodyHeight(battery_name) =
    BatteryLib_Type(battery_name) == "tube" ?
        RetrieveBatteryParameters(battery_name) [IDX_TUBE_BODY_HEIGHT] :
        RetrieveBatteryParameters(battery_name) [IDX_RECT_BODY_HEIGHT];

// Retrieve the total height of a specified battery (including the anode and
// cathode)
function BatteryLib_Height(battery_name) =
    BatteryLib_Type(battery_name) == "tube" ?
        BatteryLib_BodyHeight(battery_name) + BatteryLib_AnodeHeight(battery_name) + BatteryLib_CathodeHeight(battery_name) :
        BatteryLib_BodyHeight(battery_name) + max(BatteryLib_AnodeHeight(battery_name), BatteryLib_CathodeHeight(battery_name));

// Retrieve the diameter of the cathode of a specified battery
function BatteryLib_CathodeDiameter(battery_name) =
    BatteryLib_Type(battery_name) == "tube" ?
        RetrieveBatteryParameters(battery_name) [IDX_TUBE_CATHODE_DIAMETER] :
        RetrieveBatteryParameters(battery_name) [IDX_RECT_CATHODE_DIAMETER];

// Retrieve the height of the cathode of a specified battery
function BatteryLib_CathodeHeight(battery_name) =
    BatteryLib_Type(battery_name) == "tube" ?
        RetrieveBatteryParameters(battery_name) [IDX_TUBE_CATHODE_HEIGHT] :
        RetrieveBatteryParameters(battery_name) [IDX_RECT_CATHODE_HEIGHT];

// Retrieve the diameter of the anode of a specified battery
function BatteryLib_AnodeDiameter(battery_name) =
    BatteryLib_Type(battery_name) == "tube" ?
        RetrieveBatteryParameters(battery_name) [IDX_TUBE_ANODE_DIAMETER] :
        RetrieveBatteryParameters(battery_name) [IDX_RECT_ANODE_DIAMETER];

// Retrieve the height of the anode of a specified battery
function BatteryLib_AnodeHeight(battery_name) =
    BatteryLib_Type(battery_name) == "tube" ?
        RetrieveBatteryParameters(battery_name) [IDX_TUBE_ANODE_HEIGHT] :
        RetrieveBatteryParameters(battery_name) [IDX_RECT_ANODE_HEIGHT];

// Retrieve the horizontal distance between the anode and cathode of a
// specified battery
// This really only applies to rectangle (e.g. 9V) batteries
// For tube batteries, this just returns the body height as a sort of sane
// alternative
function BatteryLib_TerminalDistance(battery_name) =
    BatteryLib_Type(battery_name) == "tube" ?
        BatteryLib_Body_Height(battery_name) :
        RetrieveBatteryParameters(battery_name) [IDX_RECT_TERMINAL_DISTANCE];

// Retrieve the dimensions of the dimensions of a cube completely enveloping
// a specified battery [x, y, z]
function BatteryLib_Envelope(battery_name) =
    [BatteryLib_Width(battery_name), BatteryLib_Length(battery_name), BatteryLib_Height(battery_name)];
