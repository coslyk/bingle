namespace Bingle.DesktopService {

    public enum DEType {
        UNKNOWN,
        GNOME,
        CINNAMON,
        MATE,
        DEEPIN
    }

    public DEType get_de_type () {

        unowned string session_name = Environment.get_variable ("DESKTOP_SESSION");

        if ("gnome" in session_name) {
            return DEType.GNOME;
        } else if ("cinnamon" in session_name) {
            return DEType.CINNAMON;
        } else if ("mate" in session_name) {
            return DEType.MATE;
        } else if ("deepin" in session_name) {
            return DEType.DEEPIN;
        } else {
            return DEType.UNKNOWN;
        }
    }

    public void set_wallpaper (string filepath) {
        DEType de = get_de_type ();
        
        try {
            switch (de) {
                case DEType.GNOME:
                Process.spawn_command_line_sync (@"gsettings set org.gnome.desktop.background picture-uri \"file://$filepath\"");
                break;

                case DEType.CINNAMON:
                Process.spawn_command_line_sync (@"gsettings set org.cinnamon.desktop.background picture-uri \"file://$filepath\"");
                break;

                case DEType.MATE:
                Process.spawn_command_line_sync (@"gsettings set org.mate.background picture-filename \"$filepath\"");
                break;

                case DEType.DEEPIN:
                Process.spawn_command_line_sync (@"gsettings set com.deepin.wrap.gnome.desktop.background picture-uri \"file://$filepath\"");
                break;

                default: break;
            }
        } catch (SpawnError e) {
            warning ("%s\n", e.message);
        }
    }
}