
///////////////////////////////////////////// info ///////////////////////////////////////////////

// Working with SC 3.7.alpha0

// Program to play the composition Geluid van de Machine.
// Created by Robert van Heumen (c) 2011. Revision 2016.
// Commissioned by the Conlon Foundation http://www.conlon.nl.
// Composed with a grant from the Performing Arts Fund in the Netherlands.
// Premiere at the Gaudeamus Muziekweek on September 8, 2011 http://www.muziekweek.nl.
// Performed by Shackle: Anne LaBerge (flute/electronics) & Robert van Heumen (laptop instrument).

// After installing SuperCollider on a new computer, change the variable file_base into the correct path to the audio/midi files.
// Double-click on the parenthesis as indicated below to start the program.
// When the interface appears, make sure to select the correct MIDI output.

// The generic cueset only lists cues for the laptop player. The Shackle and Shackle-voice cuesets list both laptop player cues as well as acoustic player cues.

// On the Disklavier, the delay setting should read 500ms.

///////////////////////////////////////////// main loop //////////////////////////////////////

// double-click on the parenthesis at the beginning of the following line to select all the code and hit enter (on MacBooks: fn+return)
(
s.waitForBoot({

	///////////// variables /////////////

	var pID = 0; // index in next two vars
	var liveFilesLoc = ["Shackle-Kyma&SC/", "Anne-Kyma&Flute/", "Shackle-Nord&LiSa/", "Anne-Nord&Flute/"];
	var liveFilesOffsets = [ [0, 0, 1.8, 1.1, 0], [0, 0, 1.8, 1.1, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0] ];

	var version = "3.0";
	var outMainChan = if (~aBus.notNil, { ~aBus.outMain }, { 0 });
	var outLiveChan = 2;
	var countdown = 3; // countdown seconds for cues
	var dis_delay = 0.5; // delay to compensate for the Disklavier's build-in delay, when > 0.5 check timings in main task
	var file_base = Document.dir++"GvdM/Data/";
	var tape_silent = 0; // 1=tape not playing, 0=tape playing
	var players_available = 1; // set to 0 if no players available
	var disklavier_available = 1; // set to 0 if no Disklavier available
	//var client1 = NetAddr("10.0.0.2", 57121); // flute player network settings (to Max client)
	//var client1 = NetAddr("10.0.0.2", 57120); // voice player network settings (to SC client)
	var client1 = NetAddr("127.0.0.1", 57120); // on one computer
	//var client1 = NetAddr("192.168.1.58", 57120); // one-laptop version network settings
	var announce_cues = 0; // set to 1 to see NEXT CUE long before
	var volDefault = 0; // in db
	var volLiveToAltDefault = -192; // in db
	var volLiveToMainDefault = -192; // in db

	// MIDI files to be played
	var midi_file_list =
	[
		"MIDI/MIDI deel 1a.mid",
		"MIDI/MIDI deel 1c2.mid",

		//	"MIDI/MIDI deel 2a2-vel20.mid", // for Conlon Disklavier
		// "MIDI/MIDI deel 2a2-vel10.mid", // for Conlon Disklavier revised 2013 --- latest
		//	"MIDI/MIDI deel 2a2.mid", // for Conlon Disklavier  revised 2013 slightly more attack
		"MIDI/extra tracks/MIDI deel 2a2+10.mid",
		//	"MIDI/extra tracks/MIDI deel 2a2+20.mid",
		//	"MIDI/for Goldsmiths London Disklavier/MIDI deel 2a2+vel30.mid", // for Disklavier at Goldsmiths London

		"MIDI/MIDI deel 2b.mid",
		"MIDI/MIDI deel 2c.mid",

		//	"MIDI/MIDI deel 3a.mid", // for Conlon Disklavier (same velocity as in Nuendo setup)
		// "MIDI/MIDI deel 3a+vel10.mid", // for Conlon Disklavier revised 2013
		// "MIDI/MIDI deel 3a+vel20.mid", // for Conlon Disklavier revised 2013 slightly more attack --- latest
		// "MIDI/extra tracks/MIDI deel 3a+vel30.mid",
		"MIDI/extra tracks/MIDI deel 3a+vel40.mid",
		// "MIDI/extra tracks/MIDI deel 3a+vel50.mid",
		// "for Goldsmiths London Disklavier/MIDI/MIDI deel 3a+vel60.mid", // for Disklavier at Goldsmiths London,
		// for regular Disklavier with more subtle response to velocity it should probably be vel40 or vel50

		//	"MIDI/MIDI deel 3b+vel30.mid" // only on tape
	];

	// audio files to be played
	var audio_file_list =
	[
		"audio/audio deel 1.aif",
		"audio/audio deel 2a.aif",
		"audio/audio deel 2b.aif",
		"audio/audio deel 2c.aif",
		"audio/audio deel 3.aif"
	];

	// live files to be played in case no players are available
	var live_file_list =
	[
		"live/"++liveFilesLoc[pID]++"live deel 2a.aif",
		"live/"++liveFilesLoc[pID]++"live deel 2b.aif",
		"live/"++liveFilesLoc[pID]++"live deel 2c.aif",
		"live/"++liveFilesLoc[pID]++"live deel 2d.aif",
		"live/"++liveFilesLoc[pID]++"live deel 3.aif"
	];
	var live_file_offset = liveFilesOffsets[pID]; // only positive values

	// Disklavier files to be played in case no Disklavier is available
	var dis_file_list =
	[
		"Disklavier/Dis deel 1a.aif",
		"Disklavier/Dis deel 1c2.aif",
		"Disklavier/Dis deel 2a3.aif",
		"Disklavier/Dis deel 2b.aif",
		"Disklavier/Dis deel 2c.aif",
		"Disklavier/Dis deel 3a.aif"
	];

	// cue text displayed locally: Generic / Shackle / Shackle-voice
	var countdown_parts =
	[
		[
			"\nOK\nHere we go [Generic cues]",
			"\nCUE 1: switch off silent mode",
			"\nCUE 2: players enter\n\nShort dynamic-length live sampling, playback forwards-backwards with subtle pitch modulation. ",
			"\nCUE 3: disklavier back with force\n\nShort dynamic-length live sampling, playback with sample pointer offset modulation and forwards-backwards with subtle pitch modulation.",
			"\nCUE 4: disklavier break!\n\nShort break of 2s then continue, until hard cut at Cue 5.",
			"\nCUE 5: start loopy section\n\nLive sampling, playback in various time-domain patterns.",
			"\nCUE 6: disklavier back with melody\n\nLive sampling, playback with amplitude modulation resembling flutter, at will subtly changing pitch, panning and sample pointer offset.",
			"\nCUE 7: tape & players taking over\n\nShort dynamic-length live sampling, playback with sample pointer offset modulation and forwards-backwards with subtle pitch modulation.",
			"\nCUE 8: the disklavier has the last word\nAFTER BREAK:\nShort dynamic-length live sampling, playback forwards-backwards with subtle pitch modulation.",
			"\nCUE 9: players stop",
			"\nCUE 10: fade out contact mics in 15s",
			"\nThe End\nThat's it folks"
		],
		[
			"\nOK\nHere we go [Shackle cues]",
			"\nCUE 1: switch off silent mode",
			"\nCUE 2: Shackle enters\n\nR: dynrec subtle pitch.\nA: whistle tones with Nord gates, multiphonic fingerings.",
			"\nCUE 3: disklavier back with force\n\nR: dynrec subtle pitch.\nA: wild flute with multiphonics and glisses, Nord Thimble.",
			"\nCUE 4: disklavier break!\n\nShort break of 2s then continue, until hard cut at Cue 5.",
			"\nCUE 5: start loopy section\n\nR: ch8 patterns.\nA: acoustic loops - 16ths airy tone.",
			"\nCUE 6: disklavier back with melody\n\nR: ch3 ampmod.\nA: acoustic with bass line, develops rhythmically into flutter in A.",
			"\nCUE 7: tape & Shackle taking over\n\nR: dynrec no pitch.\nA: [tk] [tk] airy. Begin sparse and develop adding [π].",
			"\nCUE 8: the disklavier has the last word\nAFTER BREAK:\nR: dynrec subtle pitch.\nA: whistle tones with Nord gates, multiphonic fingerings.",
			"\nCUE 9: Shackle stops",
			"\nCUE 10: fade out contact mics in 15s",
			"\nThe End\nThat's it folks"
		],
		[
			"\nOK\nHere we go [Shackle-voice cues]",
			"\nCUE 1: switch off silent mode",
			"\nCUE 2: players enter\n\nR: dynrec subtle pitch\nS: whistling, breathy, thin sustained sounds with discontinuities.",
			"\nCUE 3: disklavier back with force\n\nR: dynrec subtle pitch\nS: wild utterings, hectic and constantly changing with some space.",
			"\nCUE 4: disklavier break!\n\nShort break of 2s then continue, until hard cut at Cue 5.",
			"\nCUE 5: start loopy section\n\nR: ch8 patterns\nS: airy loops, tonal but not too defined in timbre. Like weaving or wind through a tube.",
			"\nCUE 6: disklavier back with melody\n\nR: ch3 ampmod\nS: counterpoint to the piano, slower in tempo, dreamy humming or growling repetative melodic lines in A.",
			"\nCUE 7: tape & players taking over\n\nR: dynrec no pitch\nS: harsh vocal sounds, begin sparse and mezzoforte, then grow more dense and noisier.",
			"\nCUE 8: the disklavier has the last word\nAFTER BREAK:\nR: dynrec subtle pitch\nS: whistling, breathy, thin sustained sounds, building down towards Cue 9.",
			"\nCUE 9: players stop",
			"\nCUE 10: fade out contact mics in 15s",
			"\nThe End\nThat's it folks"
		],
		[
			"\nOK\nHere we go [Solo cues]",
			"\nCUE 1: switch off silent mode\n\nLoad blue1 & blue7, start decimate, set OS",
			"\nCUE 2: player enters\n\nZone3 HPF with decimate\nZone2 short loop\nGreenDiskPlay1 prime\nZone6 OS short loops",
			"\nCUE 3: disklavier back with force\n\nWhile playing Zone6, load blue8\nTake off OS\nZone6 bursts glissandi with reverb",
			"\nCUE 4: disklavier break!\n\nShort break of 2s then continue, until hard cut at Cue 5.\nWhen Disklavier stops goto OS",
			"\nCUE 5: start loopy section\n\nStart SynthKeys MIDI seq with Pad2, decimate, swing (K3@0.7)\nAdd processing",
			"\nCUE 6: disklavier back with melody\n\nSampling & EFX on Disklavier",
			"\nCUE 7: tape & player taking over\n\nLoad blue9\nZone6 extreme pitch in slow movements",
			"\nCUE 8: the disklavier has the last word",
			"\nCUE 9: the last chapter\n\nAdd subtle EFX on Disklavier",
			"\nCUE 10: fade out contact mics in 15s",
			"\nThe End\nThat's it folks"
		],
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

	var midi_out, midi_ports, midi_ports_lab, midi_ports_select, midi_port_default;
	var f_play_midi, midi_file, t_gvdm, f_gvdm, f_play_audio, f_play_live, f_play_dis, base_0 = 0;
	var f_countdown, b_start, start_from, start_from_val = 1, disp_cue, b_players, b_disklavier, disp_countdown;
	var buffer_array, buffer_array_live, midi_file_array, buffer_array_dis, midi_file_playing;
	var f_clock, disp_clock, clock_started = 0, t_clock;
	var cue_type, cue_type_val = 1;
	var disp_cuelist, wCueList, wCues, f_disp_cuelist_string, wCueListAvail;

	var synth = Group.new();
	var volSpec = Env.new([0,0,1,12.dbamp],[0.01,0.74,0.25],[0,5,0]);
	var volBus = Bus.control(s,1).set(0), volFader;
	var volLiveBus = Bus.control(s,1).set(0), volLiveFader;
	var volLiveToMainBus = Bus.control(s,1).set(0), volLiveToMainFader;

	if(~wControllersAvail.isNil, {(Document.dir++"Lapis/Controllers.scd").load});

	// fill buffers and load midi files
	buffer_array =
	[
		Buffer.read(s, file_base ++ audio_file_list[0]),
		Buffer.read(s, file_base ++ audio_file_list[1]),
		Buffer.read(s, file_base ++ audio_file_list[2]),
		Buffer.read(s, file_base ++ audio_file_list[3]),
		Buffer.read(s, file_base ++ audio_file_list[4])
	];

	// only if the players are not available
	if(players_available == 0, {
		buffer_array_live =
		[
			Buffer.read(s, file_base ++ live_file_list[0]),
			Buffer.read(s, file_base ++ live_file_list[1]),
			Buffer.read(s, file_base ++ live_file_list[2]),
			Buffer.read(s, file_base ++ live_file_list[3]),
			Buffer.read(s, file_base ++ live_file_list[4])
		];
	});

	// only if a Disklavier not available
	if(disklavier_available == 0, {
		buffer_array_dis =
		[
			Buffer.read(s, file_base ++ dis_file_list[0]),
			Buffer.read(s, file_base ++ dis_file_list[1]),
			Buffer.read(s, file_base ++ dis_file_list[2]),
			Buffer.read(s, file_base ++ dis_file_list[3]),
			Buffer.read(s, file_base ++ dis_file_list[4]),
			Buffer.read(s, file_base ++ dis_file_list[5])
		];
	});

	midi_file_array =
	[
		SimpleMIDIFile.read(file_base ++ midi_file_list[0]),
		SimpleMIDIFile.read(file_base ++ midi_file_list[1]),
		SimpleMIDIFile.read(file_base ++ midi_file_list[2]),
		SimpleMIDIFile.read(file_base ++ midi_file_list[3]),
		SimpleMIDIFile.read(file_base ++ midi_file_list[4]),
		SimpleMIDIFile.read(file_base ++ midi_file_list[5])
	];


	///////////// synths /////////////

	SynthDef(\audio_play, {| bufnum = 0, volBus |
		Out.ar(outMainChan,
			PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction:2) * In.kr(volBus,1)
		)
	}).send(s);

	SynthDef(\live_play, {| bufnum = 0, volBus, volToMainBus |
		Out.ar(outLiveChan,
			PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction:2) * In.kr(volBus,1)
		);
		Out.ar(outMainChan,
			PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), doneAction:2) * In.kr(volToMainBus,1)
		)
	}).send(s);

	s.sync;

	///////////// functions /////////////

	f_play_midi = {
		arg midi_file_nbr;
		("Playing" + midi_file_list[midi_file_nbr]).postln;
		midi_file_playing = (midi_file_array[midi_file_nbr].p(amp:1) <> (type: \midi, midiout: midi_out)).play;
		//	midi_file.p(amp: 1).play(protoEvent: (type: \midi, midiout: midi_out));
	};

	f_play_audio = {
		arg audio_file_nbr;
		var audio_play;
		if(tape_silent == 0, {
			("Playing" + audio_file_list[audio_file_nbr]).postln;
			audio_play = Synth(\audio_play, [\bufnum, buffer_array[audio_file_nbr],\volBus, volBus.index], target: synth);
		});
	};

	f_play_live = {
		arg live_file_nbr;
		var live_play;
		if(players_available == 0, {
			("Playing" + live_file_list[live_file_nbr]).postln;
			live_play = Synth(\live_play, [\bufnum, buffer_array_live[live_file_nbr],
				\volBus, volLiveBus.index,\volToMainBus, volLiveToMainBus.index
			], target: synth);
		});
	};

	f_play_dis = {
		arg dis_file_nbr;
		var dis_play;
		if(disklavier_available == 0, {
			("Playing" + dis_file_list[dis_file_nbr]).postln;
			dis_play = Synth(\audio_play, [\bufnum, buffer_array_dis[dis_file_nbr],\volBus, volBus.index], target: synth);
		});
	};

	f_countdown = {
		arg part;
		("\n" ++ countdown_parts[cue_type_val - 1][part]).postln;
		{
			disp_cue.background_(Color.blue);
			disp_cue.stringColor_(Color.white);
			disp_countdown.background_(Color.blue);
			disp_countdown.stringColor_(Color.white);
		}.defer();

		countdown.do({
			arg i;
			// display cue texts locally
			{
				disp_cue.string = countdown_parts[cue_type_val - 1][part];
				disp_countdown.string = (countdown - i);
			}.defer();

			// send countdown and next cue over the network
			client1.sendMsg("/count", (countdown - i));
			client1.sendMsg("/part_next", part);

			// wait
			{ disp_countdown.background_(Color.blue); disp_countdown.stringColor_(Color.white); }.defer();
			0.5.wait;
			{ disp_countdown.background_(Color.white); disp_countdown.stringColor_(Color.black); }.defer();
			0.5.wait;
		});

		// display & send 0
		{disp_countdown.string = 0;	}.defer();
		client1.sendMsg("/count", 0);
		client1.sendMsg("/part_next", part);

		//	(Date.getDate.bootSeconds - base_0).postln;
		{
			disp_cue.string = countdown_parts[cue_type_val - 1][part];
			disp_cue.background_(Color.white);
			disp_cue.stringColor_(Color.black);
		}.defer();
		{
			disp_countdown.string = "";
			disp_countdown.background_(Color.white); disp_cue.stringColor_(Color.black);
		}.defer(2);
		if(announce_cues == 1,
			{{
				disp_cue.string = "NEXT AT" + countdown_parts_time[part + 1] + countdown_parts[cue_type_val - 1][part + 1];
				disp_cue.stringColor_(Color.blue);
		}.defer(15);});
	};

	f_clock = {
		arg start;
		var min, secs;
		v = Main.elapsedTime.ceil;
		t_clock = TempoClock(1, start, v);
		t_clock.schedAbs(start, { arg beat, sec;
			// beat.asTimeStringHM.postln;
			min = (beat / 60).asInteger;
			secs = (beat % 60);
			if (secs < 10, {secs = (0.asSymbol ++ secs.asSymbol)});
			{disp_clock.string = (min.asSymbol ++ ":" ++ secs.asSymbol);}.defer(0);
			{client1.sendMsg("/clock", (min.asSymbol ++ ":" ++ secs.asSymbol));}.defer(0); // send clock to client
			1
		});
	};


	///////////// init MIDI /////////////

	if(MIDIClient.initialized == false, {MIDIClient.init});
	//midi_out = MIDIOut.newByName("UltraLite", "MIDI Port").latency_(0);
	midi_ports = MIDIClient.destinations.collect({ |x| "MIDI out to:" + x.name });
	MIDIClient.destinations.do { arg item, i;
		// MIDIClient.destinations[i].device.postln;
		// MIDIClient.destinations[i].name.postln;
		if( MIDIClient.destinations[i].device == "IAC Driver" && MIDIClient.destinations[i].name == "IAC Bus 1", {
			midi_port_default = i + 1;
			"Selected IAC Bus 1 as default MIDI out bus".postln;
		});
		if( MIDIClient.destinations[i].device == "UltraLite mk3 Hybrid" && MIDIClient.destinations[i].name == "MIDI Port", {
			midi_port_default = i + 1;
			"Selected MOTU UltraLite MIDI Port as default MIDI out bus".postln;
		});
	};
	midi_ports = midi_ports.insert(0,"Choose MIDI out port");
	if(midi_ports.size == 1, {"ERROR: there must be at least one MIDI port available!".postln;});


	///////////// OSC /////////////

	OSCdef(\gvdmCC, { |msg|
		var chan, num, value, src;
		chan = msg[1];
		num = msg[2];
		value = msg[3];
		src = msg[4].asString;
		// [chan,num,value, src].postln;

		// main volume control
		// if((chan==0 && num==7), {
		if((chan==11 && num==8), {
			// volFader.valueAction_(value);
		});
	},
	"/midi/control"
	).fix;


	///////////// tasks /////////////

	f_gvdm = {

		// playing single MIDI files separately
		//	f_play_midi.value(5);
		//	500.wait;

		// Huilend ruisen

		if(start_from_val <= 1,
			{
				f_countdown.value(0); // Start Deel 1: Here we go
				f_clock.value(0); // start clock
				clock_started = 1;
				client1.sendMsg("/part_next", 99); // to start Anne's clock - in fact i send 28?

				// base_0 = Date.getDate.secStamp;
				f_play_midi.value(0); // 0s: MIDI Deel 1a: 10 keys down
				dis_delay.wait;
				f_play_dis.value(0); // Dis deel 1a
				f_play_audio.value(0); // 0s: audio deel 1
				(158.3 - dis_delay).wait;

				f_play_midi.value(1); // 158.3s: MIDI Deel 1c2
				dis_delay.wait;
				f_play_dis.value(1); // Dis deel 1c2
				(24.9 - countdown).wait;

				f_countdown.value(1); // 183.2s - countdown: Cue 1 switch off silent mode
				(46.8 - countdown).wait;
		});

		// Grommend schreeuwen

		if(start_from_val <= 2,
			{
				f_countdown.value(2); // 230s - countdown: Start Deel 2: Cue 2 electr/flute entrance
				if(clock_started == 0, {f_clock.value(230); clock_started = 1;}); // start clock
				("Offset wait:" + live_file_offset[0]).postln;
				live_file_offset[0].wait;
				f_play_live.value(0); // live deel 2a
				( 79.2 - live_file_offset[0] ).wait;

				f_play_audio.value(1); // 309.2s: audio deel 2a
				(42.4 - countdown - dis_delay).wait;

				f_countdown.value(3); // 351.6s - countdown: Cue 3 disklavier coming back with a force
				f_play_midi.value(2); // MIDI Deel 2a: break down
				dis_delay.wait;
				f_play_dis.value(2); // Dis deel 2a3
				("Offset wait:" + live_file_offset[1]).postln;
				live_file_offset[1].wait;
				f_play_live.value(1); // live deel 2b
				( 27 - countdown - live_file_offset[1] ).wait;
				f_countdown.value(4); // 378.6s - countdown: Cue 4 break!
				(61.9 - countdown).wait;

		});

		if(start_from_val <= 3,
			{
				f_countdown.value(5); // 440.5s - countdown: Cue 5 loopy section
				if(clock_started == 0, {f_clock.value(440); clock_started = 1;}); // start clock
				f_play_audio.value(2); // audio deel 2b
				("Offset wait:" + live_file_offset[2]).postln;
				live_file_offset[2].wait;
				f_play_live.value(2); // live deel 2c
				(96.1 - countdown - dis_delay - live_file_offset[2]).wait;

				f_countdown.value(6); // 536.6s - countdown: Cue 6 Dis coming back with melody
				f_play_midi.value(3); // MIDI Deel 2b: 3vox
				dis_delay.wait;
				f_play_dis.value(3); // Dis deel 2b
				(125.4 - countdown).wait;

				f_countdown.value(7); // 662s - countdown: Cue 7 electr/flute taking over with force
				f_play_audio.value(3); // audio deel 2c
				("Offset wait:" + live_file_offset[3]).postln;
				live_file_offset[3].wait;
				f_play_live.value(3); // live deel 2d
				( 42.3 - countdown - live_file_offset[3] ).wait;

		});

		// Zoet zingen
		if(start_from_val <= 4,
			{
				f_countdown.value(8); // 704.3s - countdown: Cue 8 the disklavier has the last word
				if(clock_started == 0, {f_clock.value(704); clock_started = 1;}); // start clock
				(0.5 - dis_delay).wait;
				f_play_midi.value(4); // 704.8s: MIDI Deel 2c: dis akkoord
				dis_delay.wait;
				f_play_dis.value(4); // Dis deel 2c
				(8.2 - dis_delay).wait;

				f_play_midi.value(5); // MIDI Deel 3a: klepperdeklep/liedje
				dis_delay.wait;
				f_play_dis.value(5); // Dis deel 3a
				f_play_audio.value(4); // 713s: audio deel 3
				("Offset wait:" + live_file_offset[4]).postln;
				live_file_offset[4].wait;
				f_play_live.value(4); // live deel 3
				( 88.4 - countdown - live_file_offset[4] ).wait;

				f_countdown.value(9); // 801.4s - countdown: Cue 9 stop live electr/flute
				(64.6 - countdown).wait;

				f_countdown.value(10); // 866s - countdown: Cue 10 fade out contact mics in 15 sec
				45.wait;
		});

		// 911s: Einde
		"The End".postln;
		client1.sendMsg("/part_next", 11);
		{disp_cue.string = countdown_parts[cue_type_val - 1][11];}.defer();

	};



	///////////// user interface /////////////

	wCues = Window("The Sound of the Machine | Cues" + version + "["++liveFilesLoc[pID]++"]", Rect(10, 430, 490, 450));

	// display cues
	disp_cue = StaticText(wCues, Rect(10, 10, 470, 200)).align_(\topLeft).background_(Color.white);
	disp_cue.string = "\n...";
	disp_cue.canFocus = false;
	disp_cue.font = Font("Helvetica",25);

	// start/stop button
	b_start = Button(wCues, Rect(10, 225, 110, 70));
	b_start.states = [["Start", Color.black, Color.white],["Stop", Color.white, Color.black]];
	b_start.font_ (Font("Helvetica",25));
	b_start.action =
	{
		if(b_start.value == 1,
			{ // start
				disp_cue.string = "\n...";
				t_gvdm = Task(f_gvdm).play;
				b_players.enabled_(false);
				b_disklavier.enabled_(false);
				midi_ports_select.enabled_(false);
				start_from.enabled_(false);
				cue_type.enabled_(false);
			},
			{ // stop
				synth.free; // stop all synths in this group
				synth = Group.new(); // start the group again
				t_gvdm.stop; // stop generator
				t_clock.stop; t_clock.clear; // stop clock
				midi_file_playing.stop; // stop current midi file
				midi_out.control(0,123,0); // all MIDI notes off
				disp_clock.string = "0:00";
				"Stopped all".postln;
				disp_cue.string = "\n...";
				disp_countdown.string = "";
				disp_cue.background_(Color.white);
				disp_cue.stringColor_(Color.black);
				disp_countdown.background_(Color.white);
				disp_countdown.stringColor_(Color.black);
				b_players.enabled_(true);
				b_disklavier.enabled_(true);
				midi_ports_select.enabled_(true);
				start_from.enabled_(true);
				cue_type.enabled_(true);
				clock_started = 0;
			}
		);
	};
	b_start.canFocus = false;

	// countdown
	disp_countdown = StaticText(wCues, Rect(130, 225, 110, 70));
	disp_countdown.background=Color.white;
	disp_countdown.align = \center;
	disp_countdown.font = Font("Helvetica", 50);
	disp_countdown.string = "";

	// section to start from
	start_from = PopUpMenu(wCues, Rect(10,310,230,20));
	start_from.items = ["Choose section to start from", "Start from: Huilend ruisen", "Start from: Grommend schreeuwen 1", "Start from: Grommend schreeuwen 2", "Start from: Zoet zingen"];
	start_from.canFocus = false;
	start_from.background_(Color.white);
	start_from.font_ (Font("Helvetica",10));
	start_from.action = {if(start_from.value != 0, {start_from_val = start_from.value;});};

	// dropdown midi output
	midi_ports_select = PopUpMenu(wCues, Rect(10, 340, 230, 20));
	midi_ports_select.font_ (Font("Helvetica",10));
	midi_ports_select.background_(Color.white);
	midi_ports_select.items = midi_ports;
	midi_ports_select.action = {
		if(midi_ports_select.value != 0, {
			midi_out = MIDIOut(0, MIDIClient.destinations.at(midi_ports_select.value - 1).uid).latency_(0);
		});
	};
	midi_ports_select.canFocus = false;

	// select cue type
	cue_type = PopUpMenu(wCues, Rect(10,370,230,20));
	cue_type.items = ["Select cue type", "Cue type: Generic", "Cue type: Shackle", "Cue type: Shackle-voice", "Cue type: Solo"];
	cue_type.canFocus = false;
	cue_type.background_(Color.white);
	cue_type.font_ (Font("Helvetica",10));
	cue_type.action = {if(cue_type.value != 0, {cue_type_val = cue_type.value; f_disp_cuelist_string.value();});};

	// clock
	disp_clock = StaticText(wCues, Rect(250, 225, 230, 70));
	disp_clock.background=Color.white;
	disp_clock.align = \center;
	disp_clock.font = Font("Helvetica", 50);
	disp_clock.string = "0:00";

	// Play live files button
	b_players = Button(wCues, Rect(250, 310, 230, 20));
	b_players.states = [["NOT playing live players files", Color.black, Color.white],["Playing live players files", Color.white, Color.black]];
	b_players.font_ (Font("Helvetica",10));
	b_players.action = {
		players_available = (1 - b_players.value);
		if(players_available == 0, {
			buffer_array_live =
			[
				Buffer.read(s, file_base ++ live_file_list[0]),
				Buffer.read(s, file_base ++ live_file_list[1]),
				Buffer.read(s, file_base ++ live_file_list[2]),
				Buffer.read(s, file_base ++ live_file_list[3]),
				Buffer.read(s, file_base ++ live_file_list[4])
			];
		}, {
			buffer_array_live.do(_.free);
		});
	};
	b_players.canFocus = false;

	// Play Disklavier files button
	b_disklavier = Button(wCues, Rect(250, 340, 230, 20));
	b_disklavier.states = [["NOT playing Disklavier files", Color.black, Color.white],["Playing Disklavier files", Color.white, Color.black]];
	b_disklavier.font_ (Font("Helvetica",10));
	b_disklavier.action = {
		disklavier_available = (1 - b_disklavier.value);
		if(disklavier_available == 0, {
			buffer_array_dis =
			[
				Buffer.read(s, file_base ++ dis_file_list[0]),
				Buffer.read(s, file_base ++ dis_file_list[1]),
				Buffer.read(s, file_base ++ dis_file_list[2]),
				Buffer.read(s, file_base ++ dis_file_list[3]),
				Buffer.read(s, file_base ++ dis_file_list[4]),
				Buffer.read(s, file_base ++ dis_file_list[5])
			];
		}, {
			buffer_array_dis.do(_.free);
		});
	};
	b_disklavier.canFocus = false;

	volFader = (SmoothSlider(wCues, Rect(250, 370, 230, 20))
		// .canFocus_(false)
		.hilightColor_(Color.new255(0,0,135))
		.stringColor_(Color.white)
		.align_(\left)
		.font_(Font("Helvetica",10))
		.action_({
			var value = volSpec.at(volFader.value);
			volBus.set(value);
			volFader.string = "  " + round(value.ampdb,0.1) + "db  ( tape to main output [" + outMainChan ++ ", " ++ (outMainChan+1) ++ "] )";
	}) );

	volLiveFader = (SmoothSlider(wCues, Rect(250, 395, 230, 20))
		// .canFocus_(false)
		.hilightColor_(Color.new255(0,0,135))
		.stringColor_(Color.white)
		.align_(\left)
		.font_(Font("Helvetica",10))
		.action_({
			var value = volSpec.at(volLiveFader.value);
			volLiveBus.set(value);
			volLiveFader.string = "  " + round(value.ampdb,0.1) + "db  ( live to alt output [" + outLiveChan ++ ", " ++ (outLiveChan+1) ++ "] )";
	}) );

	volLiveToMainFader = (SmoothSlider(wCues, Rect(250, 420, 230, 20))
		// .canFocus_(false)
		.hilightColor_(Color.new255(0,0,135))
		.stringColor_(Color.white)
		.align_(\left)
		.font_(Font("Helvetica",10))
		.action_({
			var value = volSpec.at(volLiveToMainFader.value);
			volLiveToMainBus.set(value);
			volLiveToMainFader.string = "  " + round(value.ampdb,0.1) + "db  ( live to main output [" + outMainChan ++ ", " ++ (outMainChan+1) ++ "] )";
	}) );

	// window with cues
	wCueList = Window("The Sound of the Machine | CueList" + version, Rect(510,280,450,650));
	wCueListAvail = 1;
	wCueList.onClose_({
		wCueListAvail = nil;
	});

	// display cuelist
	disp_cuelist = TextView(wCueList, Rect(10, 10, 420, 630));
	disp_cuelist.canFocus = false;
	disp_cuelist.font = Font("Helvetica",12);
	f_disp_cuelist_string = {
		if(wCueListAvail == 1, {
			disp_cuelist.string =
			countdown_parts_time[0] + countdown_parts[cue_type_val-1][0].replace("\n\n","\n") ++ "\n\n" ++
			countdown_parts_time[1] + countdown_parts[cue_type_val-1][1].replace("\n\n","\n") ++ "\n\n" ++
			countdown_parts_time[2] + countdown_parts[cue_type_val-1][2].replace("\n\n","\n") ++ "\n\n" ++
			countdown_parts_time[3] + countdown_parts[cue_type_val-1][3].replace("\n\n","\n") ++ "\n\n" ++
			countdown_parts_time[4] + countdown_parts[cue_type_val-1][4].replace("\n\n","\n") ++ "\n\n" ++
			countdown_parts_time[5] + countdown_parts[cue_type_val-1][5].replace("\n\n","\n") ++ "\n\n" ++
			countdown_parts_time[6] + countdown_parts[cue_type_val-1][6].replace("\n\n","\n") ++ "\n\n" ++
			countdown_parts_time[7] + countdown_parts[cue_type_val-1][7].replace("\n\n","\n") ++ "\n\n" ++
			countdown_parts_time[8] + countdown_parts[cue_type_val-1][8].replace("\n\n","\n") ++ "\n\n" ++
			countdown_parts_time[9] + countdown_parts[cue_type_val-1][9].replace("\n\n","\n") ++ "\n\n" ++
			countdown_parts_time[10] + countdown_parts[cue_type_val-1][10].replace("\n\n","\n") ;
		});
	};
	f_disp_cuelist_string.value;

	wCues.onClose_({
		t_gvdm.stop; // stop generator
		t_clock.stop; t_clock.clear; // stop clock
		midi_file_playing.stop; // stop current midi file
		midi_out.control(0,123,0); // all MIDI notes off
		synth.free;
		client1.disconnect;
		buffer_array.do(_.free);
		buffer_array_dis.do(_.free);
		buffer_array_live.do(_.free);
		wCueList.close;
	});

	// initiate GUI
	("Live players file location:" + liveFilesLoc[pID]).postln;
	("Live players file offset:" + liveFilesOffsets[pID]).postln;
	b_players.valueAction_(1 - players_available);
	b_disklavier.valueAction_(1 - disklavier_available);
	midi_ports_select.valueAction_(midi_port_default);
	start_from.valueAction_(1);
	cue_type.valueAction_(4);
	volFader.valueAction_(volSpec.asSpec.unmap(volDefault.dbamp));
	volLiveFader.valueAction_(volSpec.asSpec.unmap(volLiveToAltDefault.dbamp));
	volLiveToMainFader.valueAction_(volSpec.asSpec.unmap(volLiveToMainDefault.dbamp));

	w = Window("dummy").front; w.close;
	wCueList.front;
	wCues.front;

});
)










