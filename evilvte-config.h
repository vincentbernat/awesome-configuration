/* Use // to disable options                                                  */

#define BACKGROUND_SATURATION  0.15
#define BACKGROUND_OPACITY     TRUE  /* True transparent background        */
#define BELL_AUDIBLE           FALSE
#define BELL_VISIBLE           FALSE
#define BELL_URGENT            FALSE
#define COLOR_BACKGROUND       "#000000"
#define COLOR_FOREGROUND       "white"
#define COLOR_STYLE   USER_CUSTOM
#define USER_COLOR_00 0x111111
#define USER_COLOR_08 0x666666
#define USER_COLOR_01 0xd36265
#define USER_COLOR_09 0xef8171
#define USER_COLOR_02 0xaece91
#define USER_COLOR_10 0xcfefb3
#define USER_COLOR_03 0xe7e18c
#define USER_COLOR_11 0xfff796
#define USER_COLOR_04 0x5297cf
#define USER_COLOR_12 0x74b8ef
#define USER_COLOR_05 0x963c59
#define USER_COLOR_13 0xb85e7b
#define USER_COLOR_06 0x5E7175
#define USER_COLOR_14 0xA3BABF
#define USER_COLOR_07 0xbebebe
#define USER_COLOR_15 0xffffff

// #define COLOR_TEXT_BOLD        "red"
// #define COLOR_TEXT_DIM         "#FFFF00"
// #define COLOR_TEXT_HIGHLIGHTED "green"
#define COMMAND_EXEC_PROGRAM   TRUE  /* -e option, execute program         */
#define COMMAND_SHOW_OPTIONS   TRUE  /* -o option, show build-time options */
#define COMMAND_SHOW_VERSION   TRUE  /* -v option, show program version    */
#define CURSOR_BLINKS          FALSE
#define CURSOR_COLOR           "green"
#define CURSOR_SHAPE           BLOCK
#define DEFAULT_COMMAND        g_getenv("SHELL")
#define DEFAULT_DIRECTORY      g_get_current_dir()
#define FONT                   "DejaVu Sans Mono for Powerline 9"
#define FONT_ANTI_ALIAS        TRUE
#define FONT_ENABLE_BOLD_TEXT  TRUE
#define PROGRAM_WM_CLASS       TRUE
#define SCROLL_LINES           5000  /* Negative value means unlimited     */
#define SCROLL_ON_KEYSTROKE    TRUE
#define SCROLL_ON_OUTPUT       FALSE
#define SCROLLBAR              OFF_R /* Options: LEFT, RIGHT, OFF_L, OFF_R */
#define SHOW_WINDOW_BORDER     FALSE
#define SHOW_WINDOW_DECORATED  FALSE
#define SHOW_WINDOW_ICON       FALSE
#define STATUS_BAR             FALSE
#define WINDOW_TITLE_DYNAMIC   TRUE
#define WORD_CHARS             "-A-Za-z0-9_$.+!*(),;:@&=?/~#%"

#define MENU                   FALSE
#define TAB                    FALSE

#define HOTKEY                       TRUE
#define HOTKEY_PASTE                 SHIFT(GDK_Insert)
#define HOTKEY_FONT_BIGGER           CTRL(GDK_plus)
#define HOTKEY_FONT_SMALLER          CTRL(GDK_minus)
#define HOTKEY_FONT_DEFAULT_SIZE     CTRL(GDK_equal)
