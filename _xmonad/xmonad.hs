import XMonad
import XMonad.Actions.Commands
import XMonad.Actions.Promote
import XMonad.Actions.Plane
import XMonad.Actions.WindowGo
import XMonad.Actions.WindowMenu
import XMonad.Actions.NoBorders
import XMonad.Actions.GridSelect
import XMonad.Actions.CycleWS

 
import XMonad.Layout.Circle
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.Maximize
import XMonad.Layout.Minimize
import XMonad.Layout.CenteredMaster
import XMonad.Layout.OneBig
import XMonad.Layout.Tabbed
import XMonad.Layout.Grid
import XMonad.Layout.DecorationMadness
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.Magnifier as Mag


import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.Place
import XMonad.Hooks.SetWMName

import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.Window
import XMonad.Prompt.AppLauncher as AL

import XMonad.Util.Themes
import XMonad.Util.Run(spawnPipe,runInTerm,safeRunInTerm,safeSpawn)
import XMonad.Util.EZConfig(additionalKeys,mkKeymap)
import XMonad.Util.Scratchpad(scratchpadSpawnActionTerminal,scratchpadSpawnAction, scratchpadManageHook, scratchpadFilterOutWorkspace)
import System.IO

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import qualified System.IO.UTF8

---------------------------------------------------------------------[ Colors ]
colorOrange          = "#ff7701"
colorDarkGray        = "#171717"
colorPink            = "#e3008d"
colorGreen           = "#00aa4a"
colorBlue            = "#008dd5"
colorYellow          = "#fee100"
colorWhite           = "#cfbfad"
                       
                                                                                                                                                                   ---------------------------------------------------------------------[ Basic ]
myNormalBGColor     = "red"
myFocusedBGColor    = "#4682b4"
myNormalFGColor     = "#ffffff"
myFocusedFGColor    = "green"
mySeperatorColor    = "#2e3436"
myStatusBarFont     = "xft:monofur,xft:微软雅黑"
myBorderWidth       = 2

-- Terminal emulator
myTerm = "urxvt"
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

-- Prefix key
myModMask = mod4Mask

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
---------------------------------------------------------------------[ Keymap ] 
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
  [ 
    -- launch a terminal
    ((modm .|. shiftMask, xK_Return),   spawn $ XMonad.terminal conf)
    -- kill
  , ((modm .|. shiftMask, xK_c     ), kill)
    -- next layout
  , ((modm, xK_space ), sendMessage NextLayout)
  , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    -- Resize viewed windows to the correct size
  , ((modm,               xK_n     ), refresh)
    -- Move focus to the next window
  , ((modm,               xK_Tab   ), windows W.focusDown)
    -- Move focus to the next window
  , ((modm,               xK_j     ), windows W.focusDown)
    -- Move focus to the previous window
  , ((modm,               xK_k     ), windows W.focusUp  )
    -- Move focus to the master window
  , ((modm,               xK_m     ), windows W.focusMaster  )
    -- Swap the focused window and the master window
  , ((modm,               xK_Return), windows W.swapMaster)
    -- Swap the focused window with the next window
  , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
    -- Swap the focused window with the previous window
  , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
    -- Shrink the master area
  , ((modm,               xK_h     ), sendMessage Shrink)
    -- Expand the master area
  , ((modm,               xK_l     ), sendMessage Expand)
    -- Push window back into tiling
  , ((modm,               xK_t     ), withFocused $ windows . W.sink)
    -- Increment the number of windows in the master area
  , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area
  , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
    -- Launch dmenu
  -- NOTE(amas): for old dmenu, ((modm, xK_p),   spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")	
  , ((modm,               xK_p     ), spawn "exe=`dmenu_run` && eval \"exec $exe\"")
    -- Relaunch xmonad 
  , ((modm, xK_q),   spawn "xmonad --recompile; xmonad --restart")
  ]-------------------------------------------------------------------
  ++
  [-------------------------------------------------------------------
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    ((m .|. modm, k), windows $ f i)
  | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
  , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
  ]-------------------------------------------------------------------
  ++
  [-------------------------------------------------------------------
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    ((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
  | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
  , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
  ]-------------------------------------------------------------------
                                                                      

myKeysa = \c -> mkKeymap c $
  [ ("M-S-<Return>", spawn $ terminal c)
  , ("M-x w", spawn "xmessage 'woohoo!'")  -- type mod+x then w to pop up 'woohoo!'
  , ("M-x y", spawn "xmessage 'yay!'")     -- type mod+x then y to pop up 'yay!'
  , ("M-q", spawn "xmonad --recompile; xmonad --restart")
  , ("M-S-c", kill)
  ]	


---------------------------------------------------------------------[ Layout ] 
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- * NOTE: XMonad.Hooks.EwmhDesktops users must remove the obsolete
-- ewmhDesktopsLayout modifier from layoutHook. It no longer exists.
-- Instead use the 'ewmh' function from that module to modify your
-- defaultConfig as a whole. (See also logHook, handleEventHook, and
-- startupHook ewmh notes.)
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
-- e.g:
-- myLayout        = avoidStruts  $  layoutHook defaultConfig
---------------------------------------------------------------------
myTabConfig = defaultTheme {
  activeColor        = "#FF0000"
  , inactiveColor    = "black"  
  , activeTextColor  = "orange"
  }


myLayout = id
           . smartBorders
           . avoidStruts
           . mkToggle (NOBORDERS ?? FULL ?? EOT)
           . mkToggle (single MIRROR)
           . Mag.magnifier
           $ centerMaster Grid
           ||| OneBig (3/4) (3/4)
           ||| tiled
           ||| Full
           ||| Circle
             where
               tiled   = Tall nmaster delta ratio
               nmaster = 1
               ratio   = 1/2
               delta   = 3/100




---------------------------------------------------------------------[ WindowsRule ]  
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
---------------------------------------------------------------------
-- placeHook simpleSmart
-- manageDocks <+> manageHook defaultConfig
myManageHook = composeAll . concat $
               [ 
                 [ className   =? c                 --> doFloat  | c <- myFloats]
               , [ title       =? t                 --> doFloat  | t <- myOtherFloats]
               , [ resource    =? r                 --> doIgnore | r <- myIgnores]
                 --, [ className   =? "Firefox-bin"     --> doF (W.shift "3:web") ]
                 --, [ className   =? "Opera"           --> doF (W.shift "3:web") ]
                 --, [ className   =? "Thunderbird-bin" --> doF (W.shift "2:mail") ]
               ]
                 where
                   myIgnores       = [""]
                   myFloats        = ["feh", "GIMP", "gimp", "gimp-2.4", "Galculator", "VirtualBox", "VBoxSDL"]
                   myOtherFloats   = ["alsamixer", "Bon Echo Preferences", "Mail/News Preferences", "Bon Echo - Restore Previous Session"] 

              
------------------------------------------------------------------------
-- Event handling
 
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH event handling to your custom event hooks by
-- combining them with ewmhDesktopsEventHook.
--
--myEventHook = mempty
 
------------------------------------------------------------------------
-- Status bars and logging
 
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH logHook actions to your custom log hook by
-- combining it with ewmhDesktopsLogHook.
--
-- e.g:
-- myLogHook = return ()
 
------------------------------------------------------------------------
-- Startup hook
 
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add initialization of EWMH support to your custom startup
-- hook by combining it with ewmhDesktopsStartup.
--
--myStartupHook = return ()
---------------------------------------------------------------------[ Dzen ]
dzenDefaults   = "  -ta l "
                 ++  "  -bg  '"  ++ myNormalBGColor
                 ++  "' -fg  '"  ++ myNormalFGColor
                 ++  "' -sa  c"
                 ++  "  -y   0"
                 ++  "  -fn   "  ++ myStatusBarFont
                
dzenXmonad     = "dzen2 -p -w 750" ++ dzenDefaults

cmdXfce4Panel  = "xfce4-panel"

myLogHook h    = dynamicLogWithPP $ myPP h

-------------------------------------------
-- NOTICE(zhoujb): snippet to support utf-8
-- import qualified System.IO.UTF8
-- -- lots of other stuff
-- ppLog = defaultPP
--   { ppOutput = \s -> do
--       h <- openFile "/home/$USER/.xmonad/xmonad.log" WriteMode
--       System.IO.UTF8.hPutStrLn h s
--       hClose h
--   }
-------------------------------------------

myPP h = defaultPP 
         { ppCurrent         = wrap "^bg(#e5f9ff)^fg(#105468)" "^bg()^fg()"
         , ppVisible         = wrap "^fg(#a00000)" "^fg()"
         , ppHidden          = wrap "^fg(#ffffff)" "^fg()"
         , ppHiddenNoWindows = wrap "^fg(#7eacb9)" "^fg()"
         , ppSep             = " | "
         , ppWsSep           = "  "
         , ppTitle           = shorten 80
         , ppOrder           = (take 3) . workspaceTag
         , ppOutput          = System.IO.UTF8.hPutStrLn h
         }
    where workspaceTag (x:xs) = ("[ " ++ x ++ " ]") : xs
---------------------------------------------------------------------[ Hooks ]
--myManageHook = composeAll
--    [ className =? "MPlayer"        --> doFloat
--    , className =? "Gimp"           --> doFloat
--    , resource  =? "desktop_window" --> doIgnore
--    , resource  =? "kdesktop"       --> doIgnore ] <+> manageDocks

---------------------------------------------------------------------[ Term ]




commands = defaultCommands




---------------------------------------------------------------------[ Main ]
main = do
  -- xmodebar
  -- xmproc <- spawnPipe "/usr/bin/xmobar /home/amas/.xmobarrc"
  -- xmonad
  -- conf <- dzen defaultConfig
  -- xxx <- spawnPipe dzenXmonad
  xfac4Panel <- spawnPipe cmdXfce4Panel
  xmonad $ defaultConfig {
    borderWidth        = myBorderWidth  
    , normalBorderColor  = "black"
    , focusedBorderColor = "red"
    , terminal           = myTerm
    , workspaces         = myWorkspaces                       
    , manageHook         = manageDocks <+>  manageHook defaultConfig
    , layoutHook         = myLayout
    , logHook            = ewmhDesktopsLogHook >> setWMName "LG3D"
    , handleEventHook    = ewmhDesktopsEventHook
    , modMask            = myModMask -- Rebind Mod to the Windows key
    , keys               = myKeys                      
    } 
    `additionalKeys`
    [
      ((mod1Mask, xK_m),     spawn "xmessage 'woohoo!'"  ) 
    , ((mod1Mask, xK_o),  scratchpadSpawnAction defaultConfig  {terminal = myTerm})  
      --, ((mod1Mask , xK_x),  scratchpadSpawnActionTerminal myTerm) 
      --, ((mod1Mask , xK_z),  promote)
    , ((mod1Mask , xK_y), commands >>= runCommand)
      --, ((mod1Mask,  xK_z),   withFocused toggleBorder)
    , ((mod4Mask,  xK_b),  raiseMaybe  (spawn "opera") (className =? "Opera"))
    , ((mod4Mask,  xK_n),  raiseMaybe  (spawn "evince") (className =? "Evince"))
    --, ((mod4Mask,  button10),  raiseMaybe  (spawn "evince") (className =? "Evince"))
    , ((mod4Mask,  xK_g),  raiseMaybe  (spawn "gvim") (className =? "Gvim"))
    , ((mod4Mask,  xK_e),  raiseMaybe  (spawn "emacs --name main.edit") (className =? "Emacs"))
    , ((mod4Mask,  xK_f),  raiseMaster  (spawn "urxvt -name main.term -e screen") (resource =? "main.term"))
    , ((mod4Mask,  xK_o),  raiseMaster  (spawn "eclipse") (resource =? "Eclipse"))
    , ((mod4Mask,  xK_g),  raiseNextMaybe (spawn "gvim") (className =? "Gvim"))
    , ((mod4Mask,  xK_i),  raiseMaybe  (spawn "inkscape") (className =? "Inkscape"))
    , ((mod4Mask,  xK_0),  windowMenu)
      --  
      -- , ((mod1Mask,  xK_0), spawnSelected defaultGSConfig ["urxvt"])
    , ((mod1Mask,  xK_0), goToSelected defaultGSConfig)
    , ((mod1Mask .|. shiftMask, xK_g     ), windowPromptGoto  defaultXPConfig)
    , ((mod1Mask .|. shiftMask, xK_b     ), windowPromptBring defaultXPConfig)
      -- 是否开启窗口自动放大模式
    , ((0, xK_F12), sendMessage Mag.Toggle)
      --, ((mod4Mask,  xK_x), shellPrompt defaultXPConfig)
    , ((0, xK_F11), sendMessage $ Toggle FULL )
    , ((mod4Mask,               xK_Down),  nextWS)
      --, ((modm,               xK_Return), windows W.swapMaster)
      -- launch app with promote in put args  
      -- , ((mod1Mask, xK_x), AL.launchApp defaultXPConfig "xpdf" )
      -- , ((mod1Mask, xK_x), AL.launchApp defaultXPConfig "urxvt" )
    ]   
