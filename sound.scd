// 서버 부팅
s.boot;

// 신디사이저 정의
(
SynthDef(\finger_synth, {
    arg freq = 440, amp = 0.5, gate = 1;
    var sig, env;
    env = EnvGen.kr(Env.adsr(0.05, 0.1, 0.5, 0.1), gate, doneAction: 2);
    sig = SinOsc.ar(freq) * env * amp;
    Out.ar(0, sig ! 2);
}).add;
)

// 전역 변수 정의
~notes = Dictionary[
    "one" -> 60,    // C4
    "two" -> 62,    // D4
    "three" -> 64,  // E4
    "four" -> 65,   // F4
    "five" -> 67,   // G4
    "y" -> 69       // A4
];
~activeNotes = Dictionary.new;

// OSC 리스너 설정
(
// 기존 OSCdef 제거
OSCdef(\from_python).free;

// 포트 닫기
NetAddr.disconnectAll;

// OSC 수신 포트 설정
thisProcess.openUDPPort(57120);

OSCdef.new(
    \from_python,
    {|msg, time, addr, recvPort|
        var label = msg[1].asString;
        var confidence = msg[2].asFloat;
        
        ["Received message:", msg, "from:", addr].postln;
        
        if(label.contains("fist"), {
            // 모든 활성 신디사이저 종료
            ~activeNotes.do({ |synth| synth.set(\gate, 0) });
            ~activeNotes.clear;
            "Stopping all notes".postln;
        }, {
            ~notes.keysValuesDo({ |key, note|
                if(label.contains(key) and: { ~activeNotes.includesKey(key).not }, {
                    var synth = Synth(\finger_synth, [
                        \freq, note.midicps,
                        \amp, confidence * 0.5
                    ]);
                    ~activeNotes[key] = synth;
                    ["Playing note:", key, note].postln;
                });
            });
        });
    },
    '/from_python',
    nil,
    57120
);

"OSC Listener ready on port 57120".postln;
)