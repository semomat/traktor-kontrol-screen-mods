import CSI 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0
import './../Definitions' as Definitions
import './../Widgets' as Widgets

// #################################
// Thanks for looking into DJ SEMs S5 Screen modding
//
// Most of the functions used here are taken from
// - NI-Forum user "Sydes"   and
// - NI-Forum user "ErikMinekus"
//
// I looked at both of their great work, and simply create my own version out of that.
// So I took some parts of the original S5 Screens (DeckFooter and DeckHeader Files) and then copy/pasted
// from Sydes and ErikMinekus, plus a bit of rearranging.

// For more info please check:
// - http://djtechtools.com/2016/09/23/hack-kontrol-s8s5-screens-advanced-layouts/
// - https://www.native-instruments.com/forum/threads/s8-s5-display-mods.288222/
// #################################

//--------------------------------------------------------------------------------------------------------------------
//  DECK HEADER
//--------------------------------------------------------------------------------------------------------------------

Item {
  id: deck_header

  // QML-only deck types
  readonly property int thruDeckType: 4

  // Placeholder variables for properties that have to be set in the elements for completeness - but are actually set
  // in the states
  readonly property int _intSetInState: 0

  // Here all the properties defining the content of the DeckHeader are listed. They are set in DeckView.
  property int    deck_Id:           0
  property string headerState:      "large" // this property is used to set the state of the header (large/small)

  readonly property variant deckLetters:        ["A",                      "B",                          "C",                  "D"                 ]
  readonly property variant textColors:         [colors.colorGrey232,  colors.colorGrey232,   colors.colorGrey232,  colors.colorGrey232 ]
  readonly property variant darkerTextColors:   [colors.colorGrey232,    colors.colorGrey232,     colors.colorGrey72,   colors.colorGrey72  ]
  // color for empty cover bg
  readonly property variant coverBgEmptyColors: [colors.colorDeckBlueDark,    colors.colorDeckBlueDark,     colors.colorGrey48,   colors.colorGrey48  ]
  // color for empty cover circles
  readonly property variant circleEmptyColors:  [colors.rgba(0, 37, 54, 255),  colors.rgba(0,  37, 54, 255),                       colors.colorGrey24,   colors.colorGrey24  ]

  readonly property variant loopText:           ["/32", "/16", "1/8", "1/4", "1/2", "1", "2", "4", "8", "16", "32"]
  readonly property variant emptyDeckCoverColor:["Blue", "Blue", "White", "White"] // deckId = 0,1,2,3

  // these variables can not be changed from outside
  readonly property int speed: 40  // Transition speed
  readonly property int smallHeaderHeight: 17
  readonly property int largeHeaderHeight: 45

  readonly property int rightMargin_middleText_large: 110
  readonly property int rightMargin_rightText_large:  38

  readonly property bool   isLoaded:    top_left_text.isLoaded
  readonly property int    deckType:    deckTypeProperty.value
  readonly property int    isInSync:    top_left_text.isInSync
  readonly property int    isMaster:    top_left_text.isMaster
  readonly property double syncPhase:   (headerPropertySyncPhase.value*2.0).toFixed(2)
  readonly property int    loopSizePos: headerPropertyLoopSize.value

  function hasTrackStyleHeader(deckType)      { return (deckType == DeckType.Track  || deckType == DeckType.Stem);  }

  // PROPERTY SELECTION
  // IMPORTANT: See 'stateMapping' in DeckHeaderText.qml for the correct Mapping from
  //            the state-enum in c++ to the corresponding state
  // NOTE: For now, we set fix states in the DeckHeader! But we wanna be able to
  //       change the states.
  property int topLeftState:      0                                 // headerSettingTopLeft.value
  property int topMiddleState:    hasTrackStyleHeader(deckType) ? 12 : 30 // headerSettingTopMid.value
  property int topRightState:     23                                // headerSettingTopRight.value

  property int bottomLeftState:   1                                 // headerSettingMidLeft.value
  property int bottomMiddleState: hasTrackStyleHeader(deckType) ? 11 : 29 // headerSettingMidMid.value
  property int bottomRightState:  25                                // headerSettingMidRight.value

  height: largeHeaderHeight
  clip: false //true
  Behavior on height { NumberAnimation { duration: speed } }

  readonly property int warningTypeNone:    0
  readonly property int warningTypeWarning: 1
  readonly property int warningTypeError:   2

  property bool isError:   (deckHeaderWarningType.value == warningTypeError)


  //--------------------------------------------------------------------------------------------------------------------
  // Helper function
  function toInt(val) { return parseInt(val); }

  //--------------------------------------------------------------------------------------------------------------------
  //  DECK PROPERTIES
  //--------------------------------------------------------------------------------------------------------------------
  AppProperty { id: deckTypeProperty;           path: "app.traktor.decks." + (deck_Id+1) + ".type" }
  AppProperty { id: directThru;                 path: "app.traktor.decks." + (deck_Id+1) + ".direct_thru"; onValueChanged: { updateHeader() } }
  AppProperty { id: headerPropertyCover;        path: "app.traktor.decks." + (deck_Id+1) + ".content.cover_md5" }
  AppProperty { id: headerPropertySyncPhase;    path: "app.traktor.decks." + (deck_Id+1) + ".tempo.phase"; }
  AppProperty { id: headerPropertyLoopActive;   path: "app.traktor.decks." + (deck_Id+1) + ".loop.active"; }
  AppProperty { id: headerPropertyLoopSize;     path: "app.traktor.decks." + (deck_Id+1) + ".loop.size"; }
  AppProperty { id: deckHeaderWarningActive;       path: "app.traktor.informer.deckheader_message." + (deck_Id+1) + ".active"; }
  AppProperty { id: deckHeaderWarningType;         path: "app.traktor.informer.deckheader_message." + (deck_Id+1) + ".type";   }
  AppProperty { id: deckHeaderWarningMessage;      path: "app.traktor.informer.deckheader_message." + (deck_Id+1) + ".long";   }
  AppProperty { id: deckHeaderWarningShortMessage; path: "app.traktor.informer.deckheader_message." + (deck_Id+1) + ".short";  }

  //--------------------------------------------------------------------------------------------------------------------
  //  STATE OF THE DECK HEADER LABELS
  //--------------------------------------------------------------------------------------------------------------------
  AppProperty { id: headerSettingTopLeft;       path: "app.traktor.settings.deckheader.top.left";  }
  AppProperty { id: headerSettingTopMid;        path: "app.traktor.settings.deckheader.top.mid";   }
  AppProperty { id: headerSettingTopRight;      path: "app.traktor.settings.deckheader.top.right"; }
  AppProperty { id: headerSettingMidLeft;       path: "app.traktor.settings.deckheader.mid.left";  }
  AppProperty { id: headerSettingMidMid;        path: "app.traktor.settings.deckheader.mid.mid";   }
  AppProperty { id: headerSettingMidRight;      path: "app.traktor.settings.deckheader.mid.right"; }

  //--------------------------------------------------------------------------------------------------------------------
  //  DJ SEMs Additional Properties
  //--------------------------------------------------------------------------------------------------------------------
  AppProperty { id: propMusicalKey;       	path: "app.traktor.decks." + (deck_Id+1) + ".content.musical_key" }
	AppProperty { id: propLegacyKey;       		path: "app.traktor.decks." + (deck_Id+1) + ".content.legacy_key" }
  AppProperty { id: propKeyDisplay;         path: "app.traktor.decks." + (deck_Id+1) + ".track.key.key_for_display" }
	AppProperty { id: propElapsedTime;    		path: "app.traktor.decks." + (deck_Id+1) + ".track.player.elapsed_time"; }
  AppProperty { id: propGridOffset;     		path: "app.traktor.decks." + (deck_Id+1) + ".content.grid_offset" }
	AppProperty { id: propTrackBpm;        		path: "app.traktor.decks." + (deck_Id+1) + ".content.bpm"; }
	AppProperty { id: propNextCuePoint;   		path: "app.traktor.decks." + (deck_Id+1) + ".track.player.next_cue_point"; }
  readonly property double  cuePos:    (propNextCuePoint.value >= 0) ? propNextCuePoint.value : propTrackLength.value*1000

/* #ifdef ENABLE_STEP_SEQUENCER */
  AppProperty { id: sequencerOn;   path: "app.traktor.decks." + (deck_Id + 1) + ".remix.sequencer.on" }
  readonly property bool showStepSequencer: (deckType == DeckType.Remix) && sequencerOn.value && (screen.flavor != ScreenFlavor.S5)
  onShowStepSequencerChanged: { updateLoopSize(); }
/* #endif */

  //--------------------------------------------------------------------------------------------------------------------
  //  UPDATE VIEW
  //--------------------------------------------------------------------------------------------------------------------

  Component.onCompleted:  { updateHeader(); }
  onHeaderStateChanged:   { updateHeader(); }
  onIsLoadedChanged:      { updateHeader(); }
  onDeckTypeChanged:      { updateHeader(); }
  onSyncPhaseChanged:     { updateHeader(); }
  onIsMasterChanged:      { updateHeader(); }

  function updateHeader() {
    updateExplicitDeckHeaderNames();
    updateCoverArt();
    updateLoopSize();
    updatePhaseSyncBlinker();
  }


  //--------------------------------------------------------------------------------------------------------------------
  //  PHASE SYNC BLINK
  //--------------------------------------------------------------------------------------------------------------------

  function updatePhaseSyncBlinker() {
    phase_sync_blink.enabled = (  headerState != "small"
                               && isLoaded
                               && !directThru.value
                               && !isMaster
                               && deckType != DeckType.Live
                               && bottom_right_text.text == "SYNC"
                               && syncPhase != 0.0 ) ? 1 : 0;
  }

  Timer {
    id: phase_sync_blink
    property bool enabled: false
    interval: 200; running: true; repeat: true
    onTriggered: bottom_right_text.visible = enabled ? !bottom_right_text.visible : true
    onEnabledChanged: { bottom_right_text.visible = true }
  }



  //--------------------------------------------------------------------------------------------------------------------
  //  DECK HEADER TEXT
  //--------------------------------------------------------------------------------------------------------------------

  Rectangle {
    id:top_line;
    anchors.horizontalCenter: parent.horizontalCenter
    width:  (headerState == "small") ? deck_header.width-18 : deck_header.width
    height: 1
    color:  textColors[deck_Id]
    Behavior on width { NumberAnimation { duration: 0.5*speed } }
  }

  Rectangle {
    id: stem_text
    width:  35; height: 14
    y: 3
    x: top_left_text.x + top_left_text.paintedWidth + 5
    color:         colors.colorBgEmpty
    border.width:  1
    border.color:  textColors[deck_Id]
    radius:        3
    opacity:        0.6

    /* #ifdef ENABLE_STEP_SEQUENCER */
    visible:       (deckType == DeckType.Stem) || showStepSequencer
    Text { x: showStepSequencer ? 5 : 3; y:1; text: showStepSequencer ? "STEP" : "STEM"; color: textColors[deck_Id]; font.pixelSize:fonts.miniFontSize }
    /* #endif */
    /* #ifndef ENABLE_STEP_SEQUENCER
    visible: deckType == DeckType.Stem
    Text { x: 3; y:1; text:"STEM"; color: textColors[deck_Id]; font.pixelSize:fonts.miniFontSize }
    #endif */
    Behavior on opacity { NumberAnimation { duration: speed } }
  }

  // top_left_text: TITEL
  DeckHeaderText {
    id: top_left_text
    deckId: deck_Id
    explicitName: ""
    maxTextWidth : (deckType == DeckType.Stem) ? 200 - stem_text.width : 300
    textState: topLeftState
    color:     textColors[deck_Id]
    elide:     Text.ElideRight
    font.pixelSize:     fonts.scale(12) // set in state
    anchors.top:        top_line.bottom
    anchors.left:       cover_small.right + 20

    anchors.topMargin:  _intSetInState  // set by 'state'
    anchors.leftMargin: _intSetInState  // set by 'state'
    Behavior on anchors.leftMargin { NumberAnimation { duration: speed } }
    Behavior on anchors.topMargin  { NumberAnimation { duration: speed } }
  }

  // bottom_left_text: ARTIST
  DeckHeaderText {
    id: bottom_left_text
    deckId: deck_Id
    explicitName: ""
    maxTextWidth : directThru.value ? 1000 : 300
    textState:  bottomLeftState
    color:      darkerTextColors[deck_Id]
    elide:      Text.ElideRight
    font.pixelSize:     fonts.scale(12)
    anchors.top:        top_line.bottom
    anchors.left:       cover_small.right + 20
    anchors.topMargin:  18
    anchors.leftMargin: 5
    Behavior on anchors.leftMargin { NumberAnimation { duration: speed } }
    Behavior on anchors.topMargin  { NumberAnimation { duration: speed } }
  }

  // ##################################################
  // Track Beats (displayed only for Track Decks)
  // All Credits for this function go to user "Sydes" (see this thread on the NI-Forums:
  // https://www.native-instruments.com/forum/threads/s8-s5-display-mods.288222/ )
  // ##################################################
  // Displays the current track beats in PP:BB.bb format. (PP : Phrases - BB : Bars - bb : beats)
  // Hightlight number in orange when counter indicates next phrase count start.
  // Set the phrase length (phraseLength : 4-8-16 phrases) (default : 8).
  // Set the beat length (beatLength : 4-8-16 beats) (default : 4).
  // Use Original Track BPM for calculations (propTrackBpm).

  readonly property int phraseLength: 8
  readonly property int beatLength: 4

  Rectangle {
    id: 					currentBeat_backgnd
    height: 				14
    width: 					55
    anchors.right: 			musickey_backgnd.left // musical key
    anchors.rightMargin: 	5
    anchors.top:       		top_line.bottom
    anchors.topMargin:    4

    function currentBeat_colorCalc() {
      var beat = ((propElapsedTime.value*1000-propGridOffset.value)*propTrackBpm.value)/60000.0
      var curBeat  = parseInt(beat);

      if ( beat < 0.0 ) {	curBeat = curBeat*-1; }

      var value1 = parseInt(((curBeat/beatLength)/phraseLength)+1);
      var value2 = parseInt(((curBeat/beatLength)%phraseLength)+1);
      var value3 = parseInt( (curBeat%beatLength)+1);

      if ( (value2 == phraseLength/2) && (value3 == beatLength) && (beat > 0.0) ) { return colors.rgba (255, 128, 0, 120); }
      if ( (value2 == phraseLength) && (value3 == beatLength) && (beat > 0.0) ) { return colors.rgba (0, 220, 0, 128); }
      if ( (value2 == 1) && (value3 == 1) && (beat < 0.0) ) { return colors.rgba (0, 220, 0, 128); }

      return colors.rgba (0, 0, 0, 100);
    }

    color: 					currentBeat_colorCalc() //colors.rgba (255, 255, 255, 16)
    visible:				isLoaded && (deckType == DeckType.Track)

    Text {
      id: 					currentBeat_text

      function currentBeat_stringCalc() {
        var beat = ((propElapsedTime.value*1000-propGridOffset.value)*propTrackBpm.value)/60000.0
        var curBeat  = parseInt(beat);

        if ( beat < 0.0 ) {	curBeat = curBeat*-1; }

        var value1 = parseInt(((curBeat/beatLength)/phraseLength)+1);
        var value2 = parseInt(((curBeat/beatLength)%phraseLength)+1);
        var value3 = parseInt( (curBeat%beatLength)+1);

        if (beat < 0.0) { return "-" + value1.toString() + ":" + value2.toString() + "." + value3.toString(); }

        return value1.toString() + ":" + value2.toString() + "." + value3.toString();
      }
      text:   				currentBeat_stringCalc()

      function currentBeat_colortextCalc() {
        var beat = ((propElapsedTime.value*1000-propGridOffset.value)*propTrackBpm.value)/60000.0
        var curBeat  = parseInt(beat);

        if ( beat < 0.0 ) {	curBeat = curBeat*-1; }

        var value1 = parseInt(((curBeat/beatLength)/phraseLength)+1);
        var value2 = parseInt(((curBeat/beatLength)%phraseLength)+1);
        var value3 = parseInt( (curBeat%beatLength)+1);

        if ( (value2 == phraseLength) && (value3 == beatLength) && (beat > 0.0) ) { return colors.rgba (0, 0, 0, 232); }
        if ( (value2 == 1) && (value3 == 1) && (beat < 0.0) ) { return colors.rgba (0, 0, 0, 232); }

        return colors.rgba (255, 255, 255, 232);
      }

      color:     				headerState == "small" ? colors.rgba (255, 255, 255, 48) : currentBeat_colortextCalc()

      font.pixelSize:     	fonts.scale(14)
      anchors.top:       		parent.top
      anchors.topMargin:  	-2
      visible:				isLoaded && (deckType == DeckType.Track)
    }
  }

  // #########################################################
  // ### BEATS TILL NEXT CUE POINT (BOTTOM - MIDDLE/RIGHT) ### - OK
  // ### Credits for this function go to user "Sydes" (see this thread on the NI-Forums:
  // ### https://www.native-instruments.com/forum/threads/s8-s5-display-mods.288222/ )
  // #########################################################
  // Displays the number of beats till next user-defined CUE point in PP:BB.bb format. (PP : Phrases - BB : Bars - bb : beats)
  // Phrase length is set @ CURRENT TRACK BEATS.
  // Beat length is set @ CURRENT TRACK BEATS.
  // Use Original Track BPM for calculations (propTrackBpm).

  Rectangle {
    id: 					nextCueBeat_backgnd
    height: 				14
    width: 					55
    anchors.right: 			musickey_backgnd.left // musical key
    anchors.rightMargin: 	5
    anchors.top:       		currentBeat_backgnd.bottom
    anchors.topMargin:  	2
    color: 					colors.rgba (0, 0, 0, 100)
    visible:				isLoaded

    Text {
      id: 					nextCueBeat_string

      function nextCueBeat_stringCalc() {
        var beat = ((propElapsedTime.value*1000-cuePos)*propTrackBpm.value)/60000.0
        var curBeat  = parseInt(beat);

        if (beat < 0.0) { curBeat = curBeat*-1; }

        var value1 = parseInt(((curBeat/beatLength)/phraseLength)+1);
        var value2 = parseInt(((curBeat/beatLength)%phraseLength)+1);
        var value3 = parseInt( (curBeat%beatLength)+1);

        if (beat < 0.0) { return "-" + value1.toString() + ":" + value2.toString() + "." + value3.toString(); }

        return value1.toString() + "." + value2.toString() + "." + value3.toString();
      }
      text:   				nextCueBeat_stringCalc()
      color:     				headerState == "small" ? colors.rgba (255, 255, 255, 48) : colors.rgba (255, 255, 255, 232)
      font.pixelSize:     	fonts.scale(14)
      anchors.top:       		parent.top
      anchors.topMargin:  	-2
      visible:				isLoaded && (deckType == DeckType.Track)
    }
  }

	// Displays the current Musical Key for the track in the first line
  // Only shown if Deck is in Track-Mode
  // Adjusts automatically if key is changed. If key is changedm current key is displayed in RED, original key in WHITE
  // second line is the original Key
	DeckHeaderText {
    	id:						"musickey_backgnd"
      deckId: deck_Id
    	width:  				50
    	height: 				14
      textState:  topRightState
      font.family: "Pragmatica" // is monospaced
      elide:      Text.ElideRight
      font.pixelSize: fonts.middleFontSize
      horizontalAlignment: Text.AlignRight
      anchors.top:          top_line.bottom
      anchors.right:        parent.right
      anchors.rightMargin:  20
      anchors.topMargin:    _intSetInState // set by 'state'
      Behavior on anchors.rightMargin { NumberAnimation { duration: speed } }
      Behavior on anchors.topMargin   { NumberAnimation { duration: speed } }
		  color:     				headerState == "small" ? colors.rgba (255, 255, 255, 16) : colors.rgba (255, 255, 255, 48)
		  visible:				isLoaded && (deckType == DeckType.Track)

    // current musical Key
		Text {
			   id: 					   "musickey_text"
			   text: 				   propKeyDisplay.value
			   color:     		 propMusicalKey.value == propKeyDisplay.value ? colors.rgba (255, 255, 255, 232) : colors.rgba (255, 0, 0, 232)
			   font.pixelSize: fonts.scale(16)
			   anchors.top:    parent.top
			   visible:				isLoaded && (deckType == DeckType.Track)
      }

    // original musical key
      Text {
        id: 					"origkey_text"
        text: 				propMusicalKey.value
        color:        colors.rgba (255, 255, 255, 232)
        font.pixelSize:     	fonts.scale(16)
        anchors.top:       		musickey_text.bottom
        anchors.topMargin: -6
        visible:				isLoaded && (deckType == DeckType.Track)
		  }
	  }


  MappingProperty { id: showBrowserOnTouch; path: "mapping.settings.show_browser_on_touch"; onValueChanged: { updateExplicitDeckHeaderNames() } }

  function updateExplicitDeckHeaderNames()
  {
    if (directThru.value) {
      top_left_text.explicitName      = "Direct Thru";
      bottom_left_text.explicitName   = "The Mixer Channel is currently In Thru mode";
      // Force the the following DeckHeaderText to be empty
      top_middle_text.explicitName    = " ";
      top_right_text.explicitName     = " ";
      bottom_middle_text.explicitName = " ";
      bottom_right_text.explicitName  = " ";
    }
    else if (deckType == DeckType.Live) {
      top_left_text.explicitName      = "Live Input";
      bottom_left_text.explicitName   = "Traktor Audio Passthru";
      // Force the the following DeckHeaderText to be empty
      top_middle_text.explicitName    = " ";
      top_right_text.explicitName     = " ";
      bottom_middle_text.explicitName = " ";
      bottom_right_text.explicitName  = " ";
    }
    else if ((deckType == DeckType.Track)  && !isLoaded) {
      top_left_text.explicitName      = "No Track Loaded!";
      bottom_left_text.explicitName   = showBrowserOnTouch.value ? "Touch Browse Knob" : "Push Browse Knob to open the Browser :)";
      // Force the the following DeckHeaderText to be empty
      top_middle_text.explicitName    = " ";
      top_right_text.explicitName     = " ";
      bottom_middle_text.explicitName = " ";
      bottom_right_text.explicitName  = " ";
    }
    else if (deckType == DeckType.Stem && !isLoaded) {
      top_left_text.explicitName      = "No Stem Loaded";
      bottom_left_text.explicitName   = showBrowserOnTouch.value ? "Touch Browse Knob" : "Push Browse Knob";
      // Force the the following DeckHeaderText to be empty
      top_middle_text.explicitName    = " ";
      top_right_text.explicitName     = " ";
      bottom_middle_text.explicitName = " ";
      bottom_right_text.explicitName  = " ";
    }
    else if (deckType == DeckType.Remix && !isLoaded) {
      top_left_text.explicitName      = " ";
      // Force the the following DeckHeaderText to be empty
      bottom_left_text.explicitName   = " ";
      top_middle_text.explicitName    = " ";
      top_right_text.explicitName     = " ";
      bottom_middle_text.explicitName = " ";
      bottom_right_text.explicitName  = " ";
    }
    else {
      // Switch off explicit naming!
      top_left_text.explicitName      = "";
      bottom_left_text.explicitName   = "";
      top_middle_text.explicitName    = "";
      top_right_text.explicitName     = "";
      bottom_middle_text.explicitName = "";
      bottom_right_text.explicitName  = "";
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
  //  Deck Letter (A, B, C or D)
  //--------------------------------------------------------------------------------------------------------------------

  Image {
    id: deck_letter_large
    anchors.top: top_line.bottom
    anchors.right: parent.right
    width: 28
    height: 36
    visible: false
    clip: true
    fillMode: Image.Stretch
    source: "./../images/Deck_" + deckLetters[deck_Id] + ".png"
    Behavior on height { NumberAnimation { duration: speed } }
    Behavior on opacity { NumberAnimation { duration: speed } }
  }

  ColorOverlay {
    id: deck_letter_color_overlay
    color: textColors[deck_Id]
    anchors.fill: deck_letter_large
    source: deck_letter_large
  }

  // Deck Letter Small
  Text {
    id: deck_letter_small
    width:               14
    height:              width
    anchors.top:         top_line.bottom
    anchors.right:       parent.right
    anchors.topMargin:   -1
    anchors.rightMargin: 6
    text:                deckLetters[deck_Id]
    color:               textColors[deck_Id]
    font.pixelSize:      fonts.middleFontSize
    font.family:         "Pragmatica MediumTT"
    opacity:             0
  }

  //--------------------------------------------------------------------------------------------------------------------
  //  WARNING MESSAGES
  //--------------------------------------------------------------------------------------------------------------------

  Rectangle {
    id: warning_box
    anchors.bottom:     parent.bottom
    anchors.topMargin:  20
    anchors.right:      deck_letter_large.left
    anchors.left:       cover_small.right
    anchors.leftMargin: 5
    height:             parent.height -1
    color:              colors.colorBlack
    visible:            deckHeaderWarningActive.value

    Behavior on anchors.leftMargin { NumberAnimation { duration: speed } }
    Behavior on anchors.topMargin  { NumberAnimation { duration: speed } }

    Text {
      id: top_warning_text
      color:              isError ? colors.colorRed : colors.colorOrange
      font.pixelSize:     fonts.largeFontSize // set in state

      text: deckHeaderWarningShortMessage.value

      anchors.top:        parent.top
      anchors.left:       parent.left
      anchors.topMargin:  -1 // set by 'state'
      Behavior on anchors.leftMargin { NumberAnimation { duration: speed } }
      Behavior on anchors.topMargin  { NumberAnimation { duration: speed } }
    }

    Text {
      id: bottom_warning_text
      color:      isError ? colors.colorRed : colors.colorOrangeDimmed
      elide:      Text.ElideRight
      font.pixelSize:     fonts.middleFontSize

      text: deckHeaderWarningMessage.value


      anchors.top:        parent.top
      anchors.left:       parent.left
      anchors.topMargin:  18
      Behavior on anchors.leftMargin { NumberAnimation { duration: speed } }
      Behavior on anchors.topMargin  { NumberAnimation { duration: speed } }
    }
  }

  Timer {
    id: warningTimer
    interval: 1200
    repeat: true
    running: deckHeaderWarningActive.value
    onTriggered: {
      if (warning_box.opacity == 1) {
        warning_box.opacity = 0;
      } else {
        warning_box.opacity = 1;
      }
    }
  }



  //--------------------------------------------------------------------------------------------------------------------
  //  STATES FOR THE DIFFERENT HEADER SIZES
  //--------------------------------------------------------------------------------------------------------------------

  state: headerState

  states: [
    State {
      name: "small";
      PropertyChanges { target: deck_header;        height: smallHeaderHeight }
      PropertyChanges { target: deck_letter_color_overlay;  opacity: 0; height: 12}
      PropertyChanges { target: deck_letter_small;  opacity: 1 }

      PropertyChanges { target: top_left_text;      font.pixelSize: fonts.middleFontSize; anchors.topMargin: -1; anchors.leftMargin: 5 }
      PropertyChanges { target: top_warning_text;   font.pixelSize: fonts.middleFontSize; anchors.topMargin: -1 }


      PropertyChanges { target: top_middle_text;    font.pixelSize: fonts.middleFontSize; anchors.topMargin: 1 }
      PropertyChanges { target: top_right_text;     font.pixelSize: fonts.middleFontSize; anchors.topMargin: 1 }
      PropertyChanges { target: bottom_left_text;   opacity: 0; }
      PropertyChanges { target: bottom_warning_text;  opacity: 0; }

      PropertyChanges { target: bottom_middle_text; opacity: 0; }
      PropertyChanges { target: bottom_right_text;  opacity: 0; }
    },
    State {
      name: "large"; //when: temporaryMouseArea.released
      PropertyChanges { target: deck_header;        height: largeHeaderHeight }
      PropertyChanges { target: deck_letter_color_overlay;  opacity: 1; width: 28; height: 36}
      PropertyChanges { target: deck_letter_small;  opacity: 0 }

      PropertyChanges { target: top_left_text;      font.pixelSize: fonts.largeFontSize;  anchors.topMargin: -2; anchors.leftMargin: (deckType.description === "Live Input" || directThru.value) ? -1 : 5}
      PropertyChanges { target: top_warning_text;   font.pixelSize: fonts.largeFontSize; anchors.topMargin: -2 }

      PropertyChanges { target: top_middle_text;    font.pixelSize: fonts.largeFontSize;  anchors.topMargin: 1 }
      PropertyChanges { target: top_right_text;     font.pixelSize: fonts.largeFontSize;  anchors.topMargin: 1 }
      PropertyChanges { target: bottom_middle_text; opacity: 1; }
      PropertyChanges { target: bottom_left_text;   opacity: 1;                                                  anchors.leftMargin: (deckType.description === "Live Input" || directThru.value) ? -1 : 5}

      PropertyChanges { target: bottom_right_text;  opacity: 1; }
    }
  ]
}
