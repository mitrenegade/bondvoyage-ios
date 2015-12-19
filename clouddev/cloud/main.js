
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
    var total = 0
    for(var i=0; i < userDicts.length; i++) {
        var dict = userDicts[i]
        var user = new Parse.User(dict)
        user.set("username", user.get("email"))

        // try to create demo user.
        console.log("creating user for " + dict["email"] + " email " + user.get("username") + " " + user.get("email") + " " + user.get("password"))
        user.signUp(null, {
            success: function(createdUser) {
                total = total + 1
                if (total == userDicts.length) {
                    response.success("seedTestUsers completed with " + total + " new users created")
                }
            },
            error: function(user, error) {
                total = total + 1
                if (total == userDicts.length) {
                    response.success("seedTestUsers completed with " + total + " new users created")
                }
            }
        })
    }
});

var randomInterests = function() {
	var interests = ["video games", "taekwondo", "surfing", "beer", "modern art", "dancing", "classical music", "rock music", "hiphop", "basketball", "hiking", "painting", "books", "web design", "hacking", "cooking"]
	var total = Math.floor(Math.random() * interests.length)
    var newInterests = []
    do {
	    var index = Math.floor(Math.random() * interests.length)
    	if (newInterests.indexOf(interests[index]) == -1) {
    		newInterests.push(interests[index])
    	}
    } while (newInterests.length < total)
    return newInterests
}

var toLowerCase = function(w) { 
    return w.toLowerCase(); 
};

Parse.Cloud.define("queryUsersWithInterests", function(request, response) {
    var interests = request.params.interests

    console.log("searching for " + interests.length + " interests: " + interests)
    var query = new Parse.Query(Parse.User)
    query.containsAll("interests", interests)
    query.find().then(function(users) {
        response.success(users)
    }, function(error) {
        response.error(error)
    });
});

