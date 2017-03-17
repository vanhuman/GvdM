
///////////////////////////////////////////// info ///////////////////////////////////////////////

// Working with SC 3.6.6

// Client Program to play the composition Geluid van de Machine.
// This program will receive the cues from the main program and is ment for the acoustic player of the piece.
// Created by Robert van Heumen (c) 2011.
// Commissioned by the Conlon Foundation http://www.conlon.nl.
// Composed with a grant from the Performing Arts Fund in the Netherlands.
// Premiere at the Gaudeamus Muziekweek on September 8, 2011 http://www.muziekweek.nl.
// Performed by Shackle: Anne LaBerge (flute/electronics) & Robert van Heumen (laptop instrument).

// Double-click on the parenthesis as indicated below to start the program.
// This version lists the cues for voice, for the performance with Robert van Heumen & Stephanie Pan.

///////////////////////////////////////////// main loop //////////////////////////////////////

// double-click on the parenthesis at the beginning of the following line to select all the code and hit enter (on MacBooks: fn+return)
(

///////////// variables /////////////

var f_osc_responder, resp_osc_part_next, resp_osc_count, resp_osc_clock;
var disp_cue, disp_countdown, disp_clock, disp_cuelist;

// cue text displayed locally
var countdown_parts =
	[
	"\n ok here we go\n Starting with tape & Disklavier.",
	"\n CUE 1: switch off silent mode",
	"\n CUE 2: voice enters\n Whistling, breathy, thin sustained sounds with discontinuities. Static until tape enters at 5:10, then build towards Cue 3.",
	"\n CUE 3: disklavier back with force\n Wild utterings, hectic and constantly changing with some space.",
	"\n CUE 4: disklavier break\n Short break of 2s then continue, until hard cut at Cue 5.",
	"\n CUE 5: start loopy section\n Airy loops, tonal but not too defined in timbre. Like weaving or wind through a tube.",
	"\n CUE 6: disklavier back with melody\n Counterpoint to the piano, slower in tempo, dreamy humming or growling repetative melodic lines in A, more open with faster piano lines (3 sections of 40s each).",
	"\n CUE 7: tape & voice taking over with force\n Harsh vocal sounds, begin sparse and mezzoforte, then grow more dense and noisier.",
	"\n CUE 8: the disklavier has the last word\n Stop abrupt, after short pause, go with the flow: whistling, breathy thin sustained sounds, building down towards Cue 9.",
	"\n CUE 9: fade out voice\n Thin out in about 20 seconds.",
	"\n CUE 10: fade out contact mics in 15 sec",
	"\n The End\n That's it folks"
	];

var countdown_parts_time =
	[
	"0:00",
	"3:03",
	"3:50",
	"5:51",
	"6:18",
	"7:20",
	"8:56",
	"11:02",
	"11:44",
	"13:21",
	"14:26",
	"15:11"
	];

///////////// functions /////////////

// OSC responder for communication with clients
f_osc_responder = {
	 	// responder to receive next part msg
		resp_osc_part_next = OSCresponderNode(nil, "part_next",{ arg time, responder, message;
			("OSC RCV: " ++ message).postln;
			// display part_next
			if(message[1] != 99,
				{{disp_cue.string = countdown_parts[message[1]];}.defer();}
				);
			}).add;

		// responder to receive the countdown
		resp_osc_count = OSCresponderNode(nil, "count",{ arg time, responder, message;
			("OSC RCV: " ++ message).postln;
			// display countdown
			{disp_countdown.string = message[1];}.defer();
			if(message[1] == 0,
				{
					{disp_countdown.string = "";}.defer(2);
					{disp_countdown.background=Color.white;}.defer(2);
					{disp_countdown.stringColor_(Color.black);}.defer(2);
					{disp_cue.background=Color.white;}.defer(0);
					{disp_cue.stringColor_(Color.black);}.defer(0);
				},
				{
					{disp_countdown.background=Color.blue;}.defer(0);
					{disp_countdown.stringColor_(Color.white);}.defer(0);
					{disp_cue.background=Color.blue;}.defer(0);
					{disp_cue.stringColor_(Color.white);}.defer(0);
				};
				);
			}).add;

		// responder to receive the clock
		resp_osc_clock = OSCresponderNode(nil, "clock",{ arg time, responder, message;
			("OSC RCV: " ++ message).postln;
			// display countdown
			{disp_clock.string = message[1];}.defer();
			}).add;
};


///////////// user interface /////////////

w = Window("Het Geluid van de Machine: Client", Rect(20, 100, 1250, 600));

// display cues
disp_cue = StaticText(w, Rect(10, 10, 780, 350)).align_(\topLeft).background_(Color.white);
disp_cue.string = "...";
disp_cue.canFocus = false;
disp_cue.font = Font("Helvetica",40);

// countdown
disp_countdown = StaticText(w, Rect(10, 380, 200, 200));
disp_countdown.background=Color.white;
disp_countdown.align = \center;
disp_countdown.font = Font("Helvetica", 100);
disp_countdown.string = "";

// clock
disp_clock = StaticText(w, Rect(230, 380, 560, 200));
disp_clock.background=Color.white;
disp_clock.align = \center;
disp_clock.font = Font("Helvetica", 100);
disp_clock.string = "0:00";

// display cuelist
disp_cuelist = TextView(w, Rect(820, 10, 420, 570));
disp_cuelist.canFocus = false;
disp_cuelist.font = Font("Helvetica",13);
disp_cuelist.string =
	countdown_parts_time[1] + countdown_parts[1].replace("\n ","\n") ++ "\n\n" ++
	countdown_parts_time[2] + countdown_parts[2].replace("\n ","\n") ++ "\n\n" ++
	countdown_parts_time[3] + countdown_parts[3].replace("\n ","\n") ++ "\n\n" ++
	countdown_parts_time[4] + countdown_parts[4].replace("\n ","\n") ++ "\n\n" ++
	countdown_parts_time[5] + countdown_parts[5].replace("\n ","\n") ++ "\n\n" ++
	countdown_parts_time[6] + countdown_parts[6].replace("\n ","\n") ++ "\n\n" ++
	countdown_parts_time[7] + countdown_parts[7].replace("\n ","\n") ++ "\n\n" ++
	countdown_parts_time[8] + countdown_parts[8].replace("\n ","\n") ++ "\n\n" ++
	countdown_parts_time[9] + countdown_parts[9].replace("\n ","\n") ++ "\n\n" ++
	countdown_parts_time[10] + countdown_parts[10].replace("\n ","\n");

// initiate GUI
w.front;
w.onClose_({
	thisProcess.stop; // to stop all processes - synths and tasks
	if(notNil(resp_osc_part_next), {resp_osc_part_next.remove});
	if(notNil(resp_osc_count), {resp_osc_count.remove});
	if(notNil(resp_osc_clock), {resp_osc_clock.remove});
});

f_osc_responder.value();

)










