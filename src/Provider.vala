namespace Bingle {

    public abstract class Provider : Object {

        public signal void finished();
        public List<ImageData> image_list = new List<ImageData>();

    }

    // Wallpaper from Bing
    public class BingProvider : Provider {
        
        public BingProvider() {
            Object ();
        }

        construct {
            // Get wallpaper of this week
            unowned string url = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=7&pid=hp&mkt=zh-CN";
            var msg = new Soup.Message ("GET", url);
            Application.network_session.queue_message (msg, on_parse_json);
        }

        // Parse JSON response
        private void on_parse_json(Soup.Session session, Soup.Message msg) {
            if (msg.status_code != 200) {
                // Fails to get the list
                error ("Fails to get wallpaper list.");
            }
            else {
                // Get wallpaper of previous week
                if (image_list.length () == 0) {
                    unowned string url = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=7&n=7&pid=hp&mkt=zh-CN";
                    var msg2 = new Soup.Message ("GET", url);
                    Application.network_session.queue_message (msg2, on_parse_json);
                }

                // Parse JSON
                var parser = new Json.Parser();
                try {
                    parser.load_from_data ((string) msg.response_body.data);
                    var images = parser.get_root ().get_object ().get_array_member ("images");

                    foreach (var item in images.get_elements ()) {
                        var image = item.get_object();
                        var filename = "Bing_" + image.get_string_member ("fullstartdate") + ".jpg";
                        unowned string description = image.get_string_member ("copyright");
                        string full_url = "https://www.bing.com" + image.get_string_member ("url");
                        string preview_url;

                        try {
                            preview_url = /(\d+x\d+)/.replace (full_url, -1, 0, "320x180");
                        } catch (RegexError e) {
                            preview_url = full_url;
                            error ("Cannot get the preview image for: %s\n", full_url);
                        }
                        this.image_list.append (new ImageData (filename, description, preview_url, full_url));
                    }
                    
                    if (image_list.length () > 7) {
                        finished ();
                    }
                }
                catch (Error e) {
                    error ("Unable to parse the response.");
                }
            }
        }
    }

    public class LocalProvider : Provider {

        construct {
            list_images.begin ((obj, res) => {
                list_images.end (res);
                finished ();
            });
        }

        // List image files
        private async void list_images () {

            var dir = File.new_for_path (Application.storage_path);
            try {
                if (!dir.query_exists ()) {
                    dir.make_directory ();
                }

                // Scan files
                var enumerator = yield dir.enumerate_children_async (FileAttribute.STANDARD_NAME, 0);
                while (true) {
                    var files = yield enumerator.next_files_async (10);
                    if (files == null) {
                        break;
                    }

                    foreach (var info in files) {
                        if (info.get_file_type () == FileType.REGULAR) {
                            var filepath = Application.storage_path + "/" + info.get_name ();
                            var image_data = new ImageData.from_local (filepath);
                            this.image_list.append ((owned) image_data);
                        }
                    }
                }
            } catch (Error e) {
                warning ("%s\n", e.message);
            }
        }
    }
}