
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("seedTestUsers", function(request, response) {
	var userDicts = [{"email": "amy@bondvoyage.com", "name": "Amy", "interests": randomInterests(), password: "test"},
            {"email": "bobby@bondvoyage.com", "name": "Bobby", "interests":  randomInterests(), password: "test"},
            {"email": "chris@bondvoyage.com", "name": "Chris", "interests":  randomInterests(), password: "test"},
            {"email": "danielle@bondvoyage.com", "name": "Danielle", "interests":  randomInterests(), password: "test"},
            {"email": "erica@bondvoyage.com", "name": "Erica", "interests":  randomInterests(), password: "test"},
            {"email": "fredson@bondvoyage.com", "name": "Fredson", "interests": randomInterests(), password: "test"},
            {"email": "ginger@bondvoyage.com", "name": "Ginger", "interests":  randomInterests(), password: "test"},
            {"email": "henry@bondvoyage.com", "name": "Henry", "interests":  randomInterests(), password: "test"},
            {"email": "irene@bondvoyage.com", "name": "Irene", "interests":  randomInterests(), password: "test"},
            {"email": "jake@bondvoyage.com", "name": "Jake", "interests": randomInterests(), password: "test"},
            {"email": "kyle@bondvoyage.com", "name": "Kyle", "interests": randomInterests(), password: "test"}
            ]
    for(var i=0; i < userDicts.length; i++) {
        var dict = userDicts[i]
        var user = new Parse.User(dict)
        user.set("username", user.get("email"))

        
        console.log("creating user for " + dict['email'] + " email " + user.get("username") + " " + user.get("email") + " " + user.get("password"))
        user.signUp(null, {
            success: function(createdUser) {
                console.log("User " + createdUser.id + " created");
            },
            error: function(user, error) {
                console.log("parse error: couldn't create user " + user + " error: " + error.message)
            }
        })
    }
    response.success("seedTestUsers seed process started");
});

var randomInterests = function() {
	var interests = ["video games", "taekwondo", "surfing", "beer", "modern art", "dancing", "classical music", "rock music", "hiphop", "basketball", "hiking", "painting", "books", "web design", "hacking", "cooking"]
	var total = Math.floor(Math.random() * interests.length)
    console.log("Generating " + total + " interests")
    var newInterests = []
    do {
	    var index = Math.floor(Math.random() * interests.length)
//    	console.log("random index " + index + " interest " + interests[index])
    	if (newInterests.indexOf(interests[index]) == -1) {
    		newInterests.push(interests[index])
//            console.log("added interest " + interests[index])
    	}
    	else {
//    		console.log("existing array contains " + interests[index])
    	}
    } while (newInterests.length < total)
    console.log("Generated interests: " + newInterests)
    return newInterests
}
