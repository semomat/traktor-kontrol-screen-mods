import QtQuick 2.0
import QtGraphicalEffects 1.0
import Traktor.Gui 1.0 as Traktor
import CSI 1.0


import '../../Defines'
import '../Templates/Deck' as Deck
import '../Templates/Browser' as Browser
import './Definitions' as Definitions
import './Overlays/' as Overlays
import './Overlays/SideOverlays' as SideOverlays
import './Widgets/' as Widgets

//----------------------------------------------------------------------------------------------------------------------
//  MAIN SCREEN - This main screen managing pretty much everything
//----------------------------------------------------------------------------------------------------------------------

Item {
  id: screen

  property bool  isLeftScreen:    true
  property bool  topInfoShown:    false
  property bool  bottomInfoShown: false
  property string settingsPath: ""
  property string propertiesPath: ""
  property var flavor

  property alias buttonArea1State:        buttonArea1.showHideState
  property alias buttonArea2State:        buttonArea2.showHideState
  property alias buttonArea1ContentState: buttonArea1.contentState
  property alias buttonArea2ContentState: buttonArea2.contentState
  property alias browserView:             browserView
  property alias screenStateAlias:        screenState.state

  // THESE PROPERTIES ARE SET BY THE HARDWARE (S8_SCREEN_WRAPPER)
  property alias  fxNavMenuValue:         overlayManager.navMenuValue
  property alias  fxNavMenuSelected:      overlayManager.navMenuSelected

  property alias  bottomControlState:     bottomControls.contentState
  property alias  bottomControlSizeState: bottomControls.sizeState
  property alias  bottomControlSmallHeight: bottomControls.smallStateHeight

  property string focusDeckContentState: "Track Deck"

  property int    upperRemixDeckRowShift: 1
  property int    lowerRemixDeckRowShift: 1

  property int    focusDeckId:            deckView.focusDeckId

  property int    browserPageSize:        browserView.pageSize
  property alias  browserIndexIncrement:  browserView.increment
  property alias  enterBrowserNode:       browserView.enterNode
  property alias  exitBrowserNode:        browserView.exitNode
  property alias  browserSortingValue:    browserView.sortingKnobValue

  property alias  centerOverlayState:     overlayManager.overlayState

  MappingProperty { id: showButtonArea;  path: propertiesPath + ".show_display_button_area"  }

  MappingProperty { id: bottomControlPage;  path: propertiesPath + ".footer_page"  }
  MappingProperty { id: bottomControlFocus; path: propertiesPath + ".footer_focus" }
  MappingProperty { id: beatgridEditMode;   path: propertiesPath + ".edit_mode"; onValueChanged: { updateButtonArea(); } }
  AppProperty   { id: isTrackLocked;      path: "app.traktor.decks." + (focusDeckId+1) + ".track.grid.lock_bpm" }
  AppProperty   { id: isTrackTick;        path: "app.traktor.decks." + (focusDeckId+1) + ".track.grid.enable_tick" }
  /* #ifdef ENABLE_STEP_SEQUENCER */
  AppProperty   { id: isSequencerOn;      path: "app.traktor.decks." + (focusDeckId+1) + ".remix.sequencer.on" }
  readonly property bool showStepSequencer: isSequencerOn.value && (screen.flavor != ScreenFlavor.S5)
  onShowStepSequencerChanged: { updateButtonArea(); }
  /* #endif */

  //--------------------------------------------------------------------------------------------------------------------

  Definitions.Font   {id: fonts}
  Definitions.Utils  {id: utils}
  Definitions.Colors {id: colors}
  Definitions.Durations {id: durations}

  width:  480
  height: 272
  clip:   true

  //--------------------------------------------------------------------------------------------------------------------
  // The black background of the screen.
  Rectangle {
    id: root
    color:          colors.colorBlack
    anchors.top:    parent.top
    anchors.left:   parent.left
    anchors.right:  parent.right
    anchors.bottom: parent.bottom
    clip:           true

    Behavior on anchors.bottomMargin { NumberAnimation { duration: durations.overlayTransition  } }

    //------------------------------------------------------------------------------------------------------------------
    //  DECK VIEW
    //------------------------------------------------------------------------------------------------------------------
    Deck.DeckView {
      id: deckView
      
      anchors.top:   parent.top
      anchors.left:  parent.left
      anchors.right: parent.right
      height:        screen.height - bottomControls.smallStateHeight
      
      settingsPath:   screen.settingsPath
      propertiesPath: screen.propertiesPath
      deckIds: isLeftScreen ? [0,2] : [1,3]
    }


    //------------------------------------------------------------------------------------------------------------------
    //  STATES SECTION
    //------------------------------------------------------------------------------------------------------------------
    Item {
      id: screenState
      state: "DeckView"
      states: [
        State {
          name: "BrowserView";
          PropertyChanges { target: browserView;    viewState: "current" }
          PropertyChanges { target: browserView;    isActive:   true     }
          PropertyChanges { target: root;           anchors.bottomMargin: 0      }
        },
        State {
          name: "DeckView";
          PropertyChanges { target: bottomControls; sizeState: bottomInfoShown ? "large" : "small"    }
          PropertyChanges { target: browserView;    viewState: "down"                                 }
          PropertyChanges { target: browserView;    isActive:   false                                 }
          PropertyChanges { target: root;           anchors.bottomMargin: bottomControls.smallStateHeight }
        }
      ]
      onStateChanged: screen.updateButtonArea()
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
  //  WIDGETs BLENDING OVER (PARTS OF) THE MAIN SCREEN
  //--------------------------------------------------------------------------------------------------------------------

  // top overlay
  Overlays.TopControls {
    id: topControls
    fxUnit:        (isLeftScreen ? 0 : 1)
    showHideState: (topInfoShown) ? "show" : "hide"
    sizeState: "large" // deckView.isDawDeckStyleFocus ? "small" : "large"
  }

  // bottom overlay
  Overlays.BottomControls {
    id: bottomControls
    contentState:   FooterPage.states[bottomControlPage.value]
    anchors.left:   parent.left
    anchors.right:  parent.right
    anchors.bottom: parent.bottom
    propertiesPath: screen.propertiesPath
    midiId:         (screen.isLeftScreen ? 0 : 4) 
    deckId:         deckView.deckIds[bottomControlFocus.value ? 1 : 0]
    focusDeckId:    deckView.focusDeckId
    fxUnit:         (screen.isLeftScreen ? 2 : 3)
    isInEditMode:   beatgridEditMode.value == 3
    sizeState:      (bottomInfoShown) ? "large" : "small"
    
    isRemixDeck:  ( ( deckView.upperDeckState == "Remix Deck" ) || (deckView.lowerDeckState == "Remix Deck") ) && ( screen.focusDeckContentState != "Stem Deck"  )
    isStemDeck:   ( ( deckView.upperDeckState == "Stem Deck"  ) || (deckView.lowerDeckState == "Stem Deck" ) ) && ( screen.focusDeckContentState != "Remix Deck" )
  }

  //--------------------------------------------------------------------------------------------------------------------

  MappingProperty { id: showSofttakeoverKnobs;   path: propertiesPath + ".softtakeover.show_knobs"   }
  MappingProperty { id: showSofttakeoverFaders;  path: propertiesPath + ".softtakeover.show_faders"  }

  Overlays.SoftTakeoverKnobs {
    id: softTakeoverKnobs

    anchors.left:  parent.left
    anchors.right: parent.right
    anchors.top:   parent.top
    visible: showSofttakeoverKnobs.value
  }

  Overlays.SoftTakeoverFaders {
    id: softTakeoverFaders

    anchors.left:   parent.left
    anchors.right:  parent.right
    anchors.bottom: parent.bottom
    visible: showSofttakeoverFaders.value
  }

  //--------------------------------------------------------------------------------------------------------------------

  Browser.BrowserView {
    id: browserView
    propertiesPath: screen.propertiesPath
  }

  //--------------------------------------------------------------------------------------------------------------------

  Overlays.OverlayManager {
    id: overlayManager
    deckId:              deckView.focusDeckId
    remixDeckId:         ( ((deckView.upperDeckState == "Remix Deck") && (deckView.lowerDeckState == "Remix Deck")) ? deckView.focusDeckId
                         : ((deckView.upperDeckState == "Remix Deck") ? deckView.upperDeckId
                         : ((deckView.lowerDeckState == "Remix Deck") ? deckView.lowerDeckId : 0)) )
    propertiesPath:      screen.propertiesPath
    bottomControlHeight: bottomControls.height
  }

  //--------------------------------------------------------------------------------------------------------------------

  // left overlay
  SideOverlays.ButtonArea {
    id: buttonArea1
    state:              "hide"
    contentState:       "TextArea"
    showHideState:      showButtonArea.value ? "show" : "hide"
    textAngle:           -90
    anchors.left:        parent.left
    anchors.leftMargin:  -6 //hides left glow & border
    scrollPosition:      (deckView.isUpperDeck) ? upperRemixDeckRowShift - 1 : lowerRemixDeckRowShift - 1
    topButtonText:       beatgridEditMode.value ? "LOCK" : "BPM"
  /* #ifdef ENABLE_STEP_SEQUENCER */
    bottomButtonText:    beatgridEditMode.value ? "TICK" : (focusDeckContentState == "Remix Deck" ? (showStepSequencer ? "SWING" : "QUANTIZE") : "KEY")
  /* #endif */
  /* #ifndef ENABLE_STEP_SEQUENCER
    bottomButtonText:    beatgridEditMode.value ? "TICK" : (focusDeckContentState == "Remix Deck" ? "QUANTIZE" : "KEY")
  #endif */
    isTopHighlighted:    (beatgridEditMode.value && isTrackLocked.value)
    isBottomHighlighted: (beatgridEditMode.value && isTrackTick.value)
  }

  // right overlay
  SideOverlays.ButtonArea {
    id: buttonArea2
    state:               "hide"
    showHideState:      showButtonArea.value ? "show" : "hide"
  /* #ifdef ENABLE_STEP_SEQUENCER */
    topButtonText:       screenState.state == "BrowserView" ? "PREP +" : (beatgridEditMode.value ? "TAP" : (focusDeckContentState == "Remix Deck" && showStepSequencer ? "1-8" : "VIEW"))
    bottomButtonText:    screenState.state == "BrowserView" ? "TO PREP" : (beatgridEditMode.value ? "RST" : (focusDeckContentState == "Remix Deck" && showStepSequencer ? "9-16" : "ZOOM"))
  /* #endif */
  /* #ifndef ENABLE_STEP_SEQUENCER
    topButtonText:       screenState.state == "BrowserView" ? "PREP +" : (beatgridEditMode.value ? "TAP" : "VIEW")
    bottomButtonText:    screenState.state == "BrowserView" ? "TO PREP" : (beatgridEditMode.value ? "RST" : "ZOOM")
  #endif */
    textAngle:           90
    anchors.right:       parent.right
    anchors.rightMargin: -6 // hides right glow & border
    contentState:        "Magnifiers"
    scrollPosition:      (deckView.isUpperDeck) ? upperRemixDeckRowShift - 1 : lowerRemixDeckRowShift - 1
  }

  //--------------------------------------------------------------------------------------------------------------------
  //  ADJUST OBJECTS TO LEFT/RIGHT SCREEN LAYOUT
  //--------------------------------------------------------------------------------------------------------------------

  onFocusDeckContentStateChanged:   updateButtonArea()
  onFocusDeckIdChanged:             updateRemixDeckRowShift()
  onUpperRemixDeckRowShiftChanged:  updateRemixDeckRowShift()
  onLowerRemixDeckRowShiftChanged:  updateRemixDeckRowShift()

  function updateButtonArea() {
    if (screenState.state == "DeckView") 
    {
      if (screen.focusDeckContentState == "Track Deck" || screen.focusDeckContentState == "Stem Deck") {
        buttonArea1.visible         = true
        buttonArea1.contentState    = "TextArea"
        buttonArea2.contentState    = (beatgridEditMode.value) ? "TextArea" : "Magnifiers"
      } else if (screen.focusDeckContentState == "Remix Deck") {

        buttonArea1.visible         = true
        buttonArea1.contentState    = "TextArea"
  /* #ifdef ENABLE_STEP_SEQUENCER */
        buttonArea2.contentState    = showStepSequencer ? "TextArea" : "ScrollBar"
  /* #endif */
  /* #ifndef ENABLE_STEP_SEQUENCER
        buttonArea2.contentState    = "ScrollBar"
  #endif */
      }
    } else if (screenState.state == "BrowserView") {
      buttonArea1.visible         = false
      buttonArea2.contentState    = "TextArea"
    }
  }

  function updateRemixDeckRowShift()
  {
    if (screen.focusDeckContentState == "Remix Deck") {
      buttonArea1.contentState        = "TextArea"
  /* #ifdef ENABLE_STEP_SEQUENCER */
      buttonArea2.contentState    = showStepSequencer ? "TextArea" : "ScrollBar"
  /* #endif */
  /* #ifndef ENABLE_STEP_SEQUENCER
      buttonArea2.contentState        = "ScrollBar"
  #endif */
      deckView.remixUpperDeckRowShift = 1 + ((upperRemixDeckRowShift - 1) * 2)
      deckView.remixLowerDeckRowShift = 1 + ((lowerRemixDeckRowShift - 1) * 2)
    }
  }
}
