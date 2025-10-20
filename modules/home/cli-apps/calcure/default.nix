{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.calcure;
  _options = options;

  # Helper to convert bool to Yes/No for config.ini
  boolToYesNo = b: if b then "Yes" else "No";

  # Generate config.ini content
  configFile = ''
    [Parameters]
    language = ${cfg.settings.language}
    default_view = ${cfg.settings.defaultView}
    default_calendar_view = ${cfg.settings.defaultCalendarView}
    start_week_day = ${toString cfg.settings.startWeekDay}
    weekend_days = ${concatStringsSep "," (map toString cfg.settings.weekendDays)}

    show_keybindings = ${boolToYesNo cfg.settings.showKeybindings}
    split_screen = ${boolToYesNo cfg.settings.splitScreen}
    privacy_mode = ${boolToYesNo cfg.settings.privacyMode}

    show_weather = ${boolToYesNo cfg.settings.showWeather}
    weather_city = ${cfg.settings.weatherCity}
    weather_metric_units = ${boolToYesNo cfg.settings.weatherMetricUnits}

    show_holidays = ${boolToYesNo cfg.settings.showHolidays}
    holiday_country = ${cfg.settings.holidayCountry}

    birthdays_from_abook = ${boolToYesNo cfg.settings.birthdaysFromAbook}
    show_moon_phases = ${boolToYesNo cfg.settings.showMoonPhases}
    show_calendar_borders = ${boolToYesNo cfg.settings.showCalendarBorders}
    show_current_time = ${boolToYesNo cfg.settings.showCurrentTime}
    show_nothing_planned = ${boolToYesNo cfg.settings.showNothingPlanned}

    use_unicode_icons = ${boolToYesNo cfg.settings.useUnicodeIcons}
    use_24_hour_format = ${boolToYesNo cfg.settings.use24HourFormat}
    use_persian_calendar = ${boolToYesNo cfg.settings.usePersianCalendar}

    minimal_today_indicator = ${boolToYesNo cfg.settings.minimalTodayIndicator}
    minimal_days_indicator = ${boolToYesNo cfg.settings.minimalDaysIndicator}
    minimal_weekend_indicator = ${boolToYesNo cfg.settings.minimalWeekendIndicator}

    cut_titles_by_cell_length = ${boolToYesNo cfg.settings.cutTitlesByCellLength}
    ask_confirmations = ${boolToYesNo cfg.settings.askConfirmations}
    ask_confirmation_to_quit = ${boolToYesNo cfg.settings.askConfirmationToQuit}
    one_timer_at_a_time = ${boolToYesNo cfg.settings.oneTimerAtATime}

    refresh_interval = ${toString cfg.settings.refreshInterval}
    data_reload_interval = ${toString cfg.settings.dataReloadInterval}
    right_pane_percentage = ${toString cfg.settings.rightPanePercentage}

    journal_header = ${cfg.settings.journalHeader}

    ${optionalString (cfg.settings.icsEventFiles != [ ]) ''
      ics_event_files = ${concatStringsSep "," cfg.settings.icsEventFiles}
    ''}
    ${optionalString (cfg.settings.icsTaskFiles != [ ]) ''
      ics_task_files = ${concatStringsSep "," cfg.settings.icsTaskFiles}
    ''}

    # Icons
    event_icon = ${cfg.settings.icons.event}
    privacy_icon = ${cfg.settings.icons.privacy}
    today_icon = ${cfg.settings.icons.today}
    birthday_icon = ${cfg.settings.icons.birthday}
    holiday_icon = ${cfg.settings.icons.holiday}
    hidden_icon = ${cfg.settings.icons.hidden}
    done_icon = ${cfg.settings.icons.done}
    todo_icon = ${cfg.settings.icons.todo}
    important_icon = ${cfg.settings.icons.important}
    separator_icon = ${cfg.settings.icons.separator}
    deadline_icon = ${cfg.settings.icons.deadline}

    [Colors]
    color_today = ${toString cfg.colors.today}
    color_events = ${toString cfg.colors.events}
    color_days = ${toString cfg.colors.days}
    color_day_names = ${toString cfg.colors.dayNames}
    color_weekends = ${toString cfg.colors.weekends}
    color_weekend_names = ${toString cfg.colors.weekendNames}
    color_hints = ${toString cfg.colors.hints}
    color_prompts = ${toString cfg.colors.prompts}
    color_confirmations = ${toString cfg.colors.confirmations}
    color_birthdays = ${toString cfg.colors.birthdays}
    color_holidays = ${toString cfg.colors.holidays}
    color_todo = ${toString cfg.colors.todo}
    color_done = ${toString cfg.colors.done}
    color_title = ${toString cfg.colors.title}
    color_calendar_header = ${toString cfg.colors.calendarHeader}
    color_important = ${toString cfg.colors.important}
    color_unimportant = ${toString cfg.colors.unimportant}
    color_timer = ${toString cfg.colors.timer}
    color_timer_paused = ${toString cfg.colors.timerPaused}
    color_time = ${toString cfg.colors.time}
    color_deadlines = ${toString cfg.colors.deadlines}
    color_weather = ${toString cfg.colors.weather}
    color_active_pane = ${toString cfg.colors.activePane}
    color_separator = ${toString cfg.colors.separator}
    color_calendar_border = ${toString cfg.colors.calendarBorder}
    color_ics_calendars = ${concatStringsSep "," (map toString cfg.colors.icsCalendars)}
    color_background = ${toString cfg.colors.background}

    [Styles]
    bold_today = ${boolToYesNo cfg.styles.boldToday}
    bold_days = ${boolToYesNo cfg.styles.boldDays}
    bold_day_names = ${boolToYesNo cfg.styles.boldDayNames}
    bold_weekends = ${boolToYesNo cfg.styles.boldWeekends}
    bold_weekend_names = ${boolToYesNo cfg.styles.boldWeekendNames}
    bold_title = ${boolToYesNo cfg.styles.boldTitle}
    bold_active_pane = ${boolToYesNo cfg.styles.boldActivePane}
    underlined_today = ${boolToYesNo cfg.styles.underlinedToday}
    underlined_days = ${boolToYesNo cfg.styles.underlinedDays}
    underlined_day_names = ${boolToYesNo cfg.styles.underlinedDayNames}
    underlined_weekends = ${boolToYesNo cfg.styles.underlinedWeekends}
    underlined_weekend_names = ${boolToYesNo cfg.styles.underlinedWeekendNames}
    underlined_title = ${boolToYesNo cfg.styles.underlinedTitle}
    underlined_active_pane = ${boolToYesNo cfg.styles.underlinedActivePane}
    strikethrough_done = ${boolToYesNo cfg.styles.strikethroughDone}

    ${optionalString (cfg.eventIcons != { }) ''
      [Event icons]
      ${concatStringsSep "\n" (mapAttrsToList (k: v: "${k} = ${v}") cfg.eventIcons)}
    ''}
  '';
in
{
  options.frgd.cli-apps.calcure = with types; {
    enable = mkBoolOpt false "Whether to enable calcure calendar and task manager";

    package = mkOpt (nullOr package) null "Custom calcure package to use";

    settings = {
      # General settings
      language = mkOpt str "en" "Interface language (en, ru, fr, it, br, tr, zh, tw, de, sk)";
      defaultView = mkOpt (enum [
        "calendar"
        "journal"
      ]) "calendar" "Default view on startup";
      defaultCalendarView = mkOpt (enum [
        "monthly"
        "daily"
      ]) "monthly" "Default calendar view type";

      # Calendar settings
      startWeekDay = mkOpt int 1 "First day of week (1=Monday, 7=Sunday)";
      weekendDays = mkOpt (listOf int) [ 6 7 ] "Weekend days (6=Saturday, 7=Sunday)";

      # Display settings
      showKeybindings = mkBoolOpt true "Show keybinding hints";
      splitScreen = mkBoolOpt true "Enable split screen view";
      privacyMode = mkBoolOpt false "Hide event/task details by default";

      # Weather
      showWeather = mkBoolOpt false "Show weather information";
      weatherCity = mkOpt str "" "City for weather display";
      weatherMetricUnits = mkBoolOpt true "Use metric units for weather";

      # Holidays and special days
      showHolidays = mkBoolOpt true "Show public holidays";
      holidayCountry = mkOpt str "UnitedStates" "Country for holiday information";
      birthdaysFromAbook = mkBoolOpt false "Import birthdays from abook";
      showMoonPhases = mkBoolOpt false "Show moon phase indicators";

      # UI elements
      showCalendarBorders = mkBoolOpt false "Show borders around calendar";
      showCurrentTime = mkBoolOpt false "Show current time";
      showNothingPlanned = mkBoolOpt true "Show 'nothing planned' message";

      # Formatting
      useUnicodeIcons = mkBoolOpt true "Use Unicode icons";
      use24HourFormat = mkBoolOpt true "Use 24-hour time format";
      usePersianCalendar = mkBoolOpt false "Use Persian calendar";

      minimalTodayIndicator = mkBoolOpt true "Use minimal today indicator";
      minimalDaysIndicator = mkBoolOpt true "Use minimal day indicators";
      minimalWeekendIndicator = mkBoolOpt true "Use minimal weekend indicators";

      cutTitlesByCellLength = mkBoolOpt false "Cut long titles to fit cell width";

      # Behavior
      askConfirmations = mkBoolOpt true "Ask for confirmations before actions";
      askConfirmationToQuit = mkBoolOpt true "Ask confirmation before quitting";
      oneTimerAtATime = mkBoolOpt false "Allow only one timer at a time";

      # Performance
      refreshInterval = mkOpt int 1 "Screen refresh interval in seconds";
      dataReloadInterval = mkOpt int 0 "Data reload interval (0=disabled)";
      rightPanePercentage = mkOpt int 25 "Width percentage of right pane";

      # ICS calendar files
      icsEventFiles = mkOpt (listOf str) [ ] "Paths to ICS event calendar files";
      icsTaskFiles = mkOpt (listOf str) [ ] "Paths to ICS task files";

      # Journal
      journalHeader = mkOpt str "JOURNAL" "Header text for journal view";

      # Icons
      icons = {
        event = mkOpt str "•" "Icon for events";
        privacy = mkOpt str "•" "Icon for private items";
        today = mkOpt str "•" "Icon for today";
        birthday = mkOpt str "★" "Icon for birthdays";
        holiday = mkOpt str "⛱" "Icon for holidays";
        hidden = mkOpt str "..." "Text for hidden items";
        done = mkOpt str "✔" "Icon for completed tasks";
        todo = mkOpt str "•" "Icon for pending tasks";
        important = mkOpt str "‣" "Icon for important tasks";
        separator = mkOpt str "│" "Separator character";
        deadline = mkOpt str "⚑" "Icon for deadlines";
      };
    };

    # Color settings (terminal color numbers 0-7 or -1 for default)
    colors = {
      today = mkOpt int 2 "Color for today's date";
      events = mkOpt int 4 "Color for events";
      days = mkOpt int 7 "Color for regular days";
      dayNames = mkOpt int 4 "Color for day names";
      weekends = mkOpt int 1 "Color for weekend days";
      weekendNames = mkOpt int 1 "Color for weekend day names";
      hints = mkOpt int 7 "Color for hints";
      prompts = mkOpt int 7 "Color for prompts";
      confirmations = mkOpt int 1 "Color for confirmation messages";
      birthdays = mkOpt int 1 "Color for birthdays";
      holidays = mkOpt int 2 "Color for holidays";
      todo = mkOpt int 7 "Color for todo items";
      done = mkOpt int 6 "Color for completed items";
      title = mkOpt int 4 "Color for titles";
      calendarHeader = mkOpt int 4 "Color for calendar header";
      important = mkOpt int 1 "Color for important tasks";
      unimportant = mkOpt int 6 "Color for unimportant tasks";
      timer = mkOpt int 2 "Color for active timers";
      timerPaused = mkOpt int 7 "Color for paused timers";
      time = mkOpt int 7 "Color for time display";
      deadlines = mkOpt int 3 "Color for deadlines";
      weather = mkOpt int 2 "Color for weather information";
      activePane = mkOpt int 2 "Color for active pane indicator";
      separator = mkOpt int 7 "Color for separators";
      calendarBorder = mkOpt int 7 "Color for calendar borders";
      icsCalendars = mkOpt (listOf int) [
        2
        3
        1
        7
        4
        5
        2
        3
        1
        7
      ] "Colors for ICS calendars";
      background = mkOpt int (-1) "Background color (-1 for default)";
    };

    # Style settings
    styles = {
      boldToday = mkBoolOpt false "Bold text for today";
      boldDays = mkBoolOpt false "Bold text for days";
      boldDayNames = mkBoolOpt false "Bold text for day names";
      boldWeekends = mkBoolOpt false "Bold text for weekends";
      boldWeekendNames = mkBoolOpt false "Bold text for weekend names";
      boldTitle = mkBoolOpt false "Bold text for titles";
      boldActivePane = mkBoolOpt false "Bold text for active pane";
      underlinedToday = mkBoolOpt false "Underline today's date";
      underlinedDays = mkBoolOpt false "Underline days";
      underlinedDayNames = mkBoolOpt false "Underline day names";
      underlinedWeekends = mkBoolOpt false "Underline weekends";
      underlinedWeekendNames = mkBoolOpt false "Underline weekend names";
      underlinedTitle = mkBoolOpt false "Underline titles";
      underlinedActivePane = mkBoolOpt false "Underline active pane";
      strikethroughDone = mkBoolOpt false "Strikethrough completed tasks";
    };

    # Event icon mappings (keyword -> icon)
    eventIcons = mkOpt (attrsOf str) { } ''
      Mapping of keywords to icons for events.
      Example: { travel = "✈"; meeting = "🎙️"; }
    '';
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      let
        placeholder = writeShellScriptBin "calcure" ''
          #!/bin/sh
          echo "calcure is not yet available in nixpkgs."
          echo "Consider packaging it or using an overlay."
          exit 1
        '';
        calcurePkg =
          if cfg.package != null then
            cfg.package
          else if pkgs ? calcure then
            pkgs.calcure
          else
            placeholder;
      in
      [ calcurePkg ];

    home.file = {
      ".config/calcure/config.ini".text = configFile;
      ".local/share/calcure/.keep".text = "";
    };
  };
}
