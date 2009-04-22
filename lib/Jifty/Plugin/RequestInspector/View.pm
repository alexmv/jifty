package Jifty::Plugin::RequestInspector::View;
use strict;
use warnings;
use Jifty::View::Declare -base;

template '/__jifty/admin/requests' => page {
    title => "Request Inspector"
}
content {
    my $request_inspector = Jifty->find_plugin('Jifty::Plugin::RequestInspector');

    ol {
        attr { id is 'request-inspector' };

        for my $request ($request_inspector->requests) {
            li {
                my $id = $request->{id};

                hyperlink(
                    label => $request->{url},
                    onclick => {
                        element   => "#request-$id",
                        replace_with => '/__jifty/admin/requests/plugins',
                        toggle    => 1,
                        effect    => 'slideDown',
                        arguments => {
                            id => $id,
                        },
                    },
                );

                outs sprintf ' (%.2gs)',  $request->{end} - $request->{start};

                div { attr { id is "request-$id" } };
            };
        }
    };
};

template '/__jifty/admin/requests/plugins' => sub {
    my $id = get('id');
    my $request_inspector = Jifty->find_plugin('Jifty::Plugin::RequestInspector');
    my $request = $request_inspector->get_request($id);

    dl {
        for my $plugin_name (sort keys %{ $request->{plugin_data} }) {
            my $row_id = "request-$id-$plugin_name";
            $row_id =~ s/::/-/g;

            my $plugin_data = $request->{plugin_data}{$plugin_name};
            my $plugin = Jifty->find_plugin($plugin_name);

            dt {
                (my $short_name = $plugin_name) =~ s/^Jifty::Plugin:://;
                hyperlink(
                    label => $short_name,
                    onclick => {
                        element => "#$row_id",
                        replace_with => '/__jifty/admin/requests/plugin',
                        toggle  => 1,
                        effect  => 'slideDown',
                        arguments => {
                            id => $id,
                            plugin_name => $plugin_name,
                        },
                    },
                );
            };
            dd {
                outs $plugin->inspect_render_summary($plugin_data);
                div { attr { id is $row_id } };
            };
        }
    };
};

template '/__jifty/admin/requests/plugin' => sub {
    my $id = get('id');
    my $plugin_name = get('plugin_name');

    my $request_inspector = Jifty->find_plugin('Jifty::Plugin::RequestInspector');
    my $plugin_data = $request_inspector->get_plugin_data($id, $plugin_name);

    my $plugin = Jifty->find_plugin($plugin_name)
        or abort(404);

    $plugin->inspect_render_analysis($plugin_data);
};

1;

