if (typeof Jifty == "undefined") Jifty = { };

{

    /* onPushHandler is called for each new pushed element.
       (currently, this is always a <pushfrag>).
       This routine takes the pushed element and extracts render mode (Before, After, Replace, Delete)
       , region name and other rendering information. Then it calls jifty's "apply_fragment_updates to the
       item inside the <pushfrag> (the actual fragment);

        f is the specification for the new fragment. (region, path, mode and other infomration extracted from the fragment)

       */

    var onPushHandler = function(t) {
    	var mode = t.attributes['mode'].nodeValue;
    	var rid =  t.firstChild.attributes['id'].nodeValue;
    	var f = { region: rid, path: '', mode: mode };
    	f = prepare_element_for_update(f);
    	apply_fragment_updates(t.firstChild, f);
    };



    
    /* This function constructs a new Jifty.Subs object and sets up a callback with HTTP.Push to run our onPushHandler each time a new element is added to the hidden iframe's body. 

    We could instead say "sets up our transport. every time the transport gets a new item, call onPushHandler"
    */

    /* Jifty.Subs.start() will connect to the transport */

    Jifty.Subs = function(args) {
    	var window_id = args.window_id; // XXX: not yet
    	var uri = args.uri;
    	if (!uri)
    	    uri = "/=/subs_infinite_iframe?";
    	var push = new HTTP.Push({ "uri": uri, interval : 100,
    				       "onPush" : onPushHandler});
    	
    	this.start = function() {
    	    push.start();
    	};
    }
}
