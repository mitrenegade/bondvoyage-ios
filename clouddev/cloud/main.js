// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
 
Parse.Cloud.define("seedTestUsers", function(request, response) {
    var userDicts = [{"email": "amy@bondvoyage.com", "firstName": "Amy", "interests": randomInterests(), password: "test", birthYear: 2016 - 21, gender: "female"},
            {"email": "bobby@bondvoyage.com", "firstName": "Bobby", "interests":  randomInterests(), password: "test", birthYear: 2016 - 32, gender: "male"},
            {"email": "chris@bondvoyage.com", "firstName": "Chris", "interests":  randomInterests(), password: "test", birthYear: 2016 - 29, gender: "male"},
            {"email": "danielle@bondvoyage.com", "firstName": "Danielle", "interests":  randomInterests(), password: "test", birthYear: 2016 - 45, gender: "female"},
            {"email": "erica@bondvoyage.com", "firstName": "Erica", "interests":  randomInterests(), password: "test", birthYear: 2016 - 28, gender: "female"},
            {"email": "fred@bondvoyage.com", "firstName": "Fred", "interests": randomInterests(), password: "test", birthYear: 2016 - 32, gender: "male"},
            {"email": "ginger@bondvoyage.com", "firstName": "Ginger", "interests":  randomInterests(), password: "test", birthYear: 2016 - 26, gender: "female"},
            {"email": "henry@bondvoyage.com", "firstName": "Henry", "interests":  randomInterests(), password: "test", birthYear: 2016 - 14, gender: "male"},
            {"email": "irene@bondvoyage.com", "firstName": "Irene", "interests":  randomInterests(), password: "test", birthYear: 2016 - 22, gender: "female"},
            {"email": "jake@bondvoyage.com", "firstName": "Jake", "interests": randomInterests(), password: "test", birthYear: 2016 - 42, gender: "male"},
            {"email": "kyle@bondvoyage.com", "firstName": "Kyle", "interests": randomInterests(), password: "test", birthYear: 2016 - 18, gender: "male"}
            ]
    var total = 0

    Parse.Cloud.useMasterKey()

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
 
Parse.Cloud.define("seedTestRecommendations", function(request, response) {
    var dicts = [{"name": "Coffee on the Esplanade", "description": "Drink coffee with me. Enjoy the outdoors.", interests: ["coffee", "tea", "outdoors"]},
            {"name": "Boston Bar crawl", "description": "Meet up at the Crossroads, go down Boylston St until we get hammered", interests: ["beer", "wine", "liquor", "rock music"]},
            {"name": "Sports day on the Commons", "description": "Let's enjoy the weather and play some pick up sports", interests: ["basketball", "taekwondo", "surfing", "hiking", "soccer", "frisbee", "ultimate"]},
            {"name": "Clubbing and Dancing", "description": "I don't even know what clubs still exist in Boston", interests: ["beer", "liquor", "wine", "dancing", "rock music", "hiphop"]},
            {"name": "Game night", "description": "Get some beer and pizza, stay in and chill. Netflix?", interests: ["beer", "liquor", "wine", "movies", "video games"]},
            {"name": "Free concert", "description": "Attend a free concert featuring the music of David Bowie", interests: ["beer", "liquor", "rock music", "dancing"]},
            {"name": "BOGO Duck Tours", "description": "See the city from land and sea! Bring a friend", interests: ["sightseeing", "tours", "architecture", "city", "food"]},
            {"name": "Free dessert with coffee", "description": "Drink Starbucks and get a scone with that latte", interests: ["coffee", "pastries", "desserts"]},
            {"name": "Hamilton tickets", "description": "Rush tickets still available", interests: ["shows", "broadway", "dancing", "singing", "hiphop"]},
            {"name": "Karaoke", "description": "Get one free drink at the karaoke lounge", interests: ["singing", "liquor", "beer"]},
            {"name": "Sushi", "description": "Half off sake bombs and hand rolls", interests: ["food", "seafood", "liquor", "beer"]},
            {"name": "Salsa at Ryles", "description": "Free beginner lessons at 9 PM", interests: ["dancing", "latin", "beer", "liquor"]},
            {"name": "Legal Seafoods", "description": "Experience Boston's famous Lobsta roll", interests: ["food", "seafood"]}
            ]
    var total = 0
 
    Parse.Cloud.useMasterKey()
     
    var Recommendation = Parse.Object.extend("Recommendation")
    for(var i=0; i < dicts.length; i++) {
        var dict = dicts[i]
        console.log("creating recommendation " + dict["name"])

        var newRecommendation = new Recommendation(dict)

        /*
        var relation = newEvent.relation("users")
        var randos = randomUsers(allUsers)
        for (var j=0; j<randos.length; j++) {
            var user = randos[j]
            relation.add(user)
        }
        */
        newRecommendation.save().then(
            function(object) {
                total = total + 1
                if (total == dicts.length) {
                    response.success("seedTestRecommendations completed with " + total + " new recommendations created")
                }
            },
            function(error) {
                total = total + 1
                if (total == dicts.length) {
                    response.success("seedTestRecommendations completed with error, " + total + " new recommendations created")
                }
            }
        )
    }
});
 
Parse.Cloud.afterSave("Event", function(request,response){
    // add random users to Event for test
    Parse.Cloud.useMasterKey()
 
    // load all users
    var relation = request.object.relation("users")
    relation.query().find({
        success: function(results) {
            console.log("found " + results.length + " users for event")
            var total = 0
            for (var j=0; j<results.length; j++) {
                var user = results[j]
                var userRelation = user.relation("events")
                userRelation.add(request.object)
                user.save().then(
                    function(object) {
                        console.log("user added event")
                        total = total + 1
                        if (total == results.length) {
                            response.success("users updated with new event: " + total)
                        }
                    }, 
                    function(error) {
                        console.log("user could not add event " + error.message)
                        total = total + 1
                        if (total == results.length) {
                            response.error("ignoring error for adding event relations to users")
                        }
                    }
                )
            }
        },
        error: function(error) {
            console.log("could not generate random users for event")
            // ignore error
            response.error("could not generate random users for event")
        }
    })
})
 
var randomInterests = function() {
    var interests = ["coffee", "tea", "movies", "video games", "taekwondo", "surfing", "beer", "wine", "liquor", "modern art", "dancing", "classical music", "rock music", "hiphop", "basketball", 
    "hiking", "painting", "books", "web design", "hacking", "cooking", "soccer", "frisbee", "ultimate", "sightseeing", "tours", "architecture", "city", "food", "pastries", "desserts", "shows", 
    "broadway", "theatre", "singing", "seafood", "latin"]
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
 
var randomUsers = function(users) {
    var total = Math.floor(Math.random() * users.length)
    var newUsers = []
    do {
        var index = Math.floor(Math.random() * users.length)
        if (newUsers.indexOf(users[index]) == -1) {
            newUsers.push(users[index])
        }
    } while (newUsers.length < total)
    return newUsers
}
 
var toLowerCase = function(w) { 
    return w.toLowerCase(); 
};
 
Parse.Cloud.define("queryUsers", function(request, response) {
    var interests = request.params.interests
 
    var genderOptions = request.params.gender
    if (genderOptions != undefined) {
        if (genderOptions.length == 0) {
            genderOptions = ["male", "female"]
        }
        // TODO: error if gender options are invalid. or, ignore?
    }
 
    var ageOptions = request.params.age // can be a single number or a range
    if (ageOptions != undefined) {
        if (ageOptions.length == 0) {
            ageOptions = [0, 99]
        }
        else if (ageOptions.length == 1) {
            var age = ageOptions[0]
            ageOptions = [age - 2, age + 2]
        }
        // TODO: error if age range is invalid
    }
 
    // only relevant for events or groups...not search results
    var numberOptions = request.params.number // can be a single number or a range
    if (numberOptions != undefined) {
        if (numberOptions.length == 0) {
            numberOptions = [99]
        }
        var max = numberOptions[0]
        if (numberOptions.length > 1) {
            max = numberOptions[1]
        }
        // TODO: error if number range is invalid
    }
 
    interests = interests.map(toLowerCase)
    console.log("searching for " + interests.length + " interests: " + interests)

    var query = new Parse.Query(Parse.User)
    query.containsAll("interests", interests)

    if (genderOptions != undefined) {
        query.containedIn("gender", genderOptions)
    }
    if (ageOptions != undefined) {
        var yearMax = 2016 - ageOptions[0]
        var yearMin = 2016 - ageOptions[1]
        query.greaterThanOrEqualTo("birthYear", yearMin)
        query.lessThanOrEqualTo("birthYear", yearMax)
    }

    console.log("calling query.find")
    query.find({
        success: function(users) {
            console.log("Results count " + users.length)
            response.success(users)
        },
        error: function(error) {
            console.log("query failed: error " + error)
            response.error(error)
        }         
    })
});

Parse.Cloud.define("queryRecommendations", function(request, response) {
    var location = request.params.location // not used
    var interests = request.params.interests
 
    var query = new Parse.Query("Recommendation")

    if (interests.length > 0) {
        interests = interests.map(toLowerCase)
        console.log("searching for " + interests.length + " interests: " + interests)
        query.containsAll("interests", interests)
    }
    query.descending("updatedAt")

    console.log("calling query.find")
    query.find({
        success: function(recommendations) {
            console.log("Results count " + recommendations.length)
            response.success(recommendations)
        },
        error: function(error) {
            console.log("query failed: error " + error)
            response.error(error)
        }         
    })
});

Parse.Cloud.define("inviteUser", function(request, response) {
    var fromUser = request.user
    var toUserId = request.params.user
    var interests = request.params.interests
    var query = new Parse.Query('_User')
    query.get(toUserId).then(
        function(result) {
            console.log("Sending push message to user " + toUserId + " from " + fromUser)
            sendPushInviteUser(response, fromUser, toUserId, interests)
        },
        function(error) {
            console.log("Could not load user for inviting")
            response.error("Could not find user to invite")
        }     
    )
})
var sendPushInviteUser = function(response, fromUser, toId, interests) {
    console.log("inside send push")
    console.log("from user " + fromUser + " toId " + toId + " interests " + interests)
    var name = fromUser.get("firstName")
    if (name == undefined) {
        name = fromUser.get("lastName")
    }
    var message = name + " has sent you an invitation to bond over " + interests[0]
    if (name == undefined) {
        message = "You have received an invitation to bond over " + interests[0]
    }
    var channel = "channel" + toId
    Parse.Push.send({
        channels: [ channel ],
        data: {
            alert: message,
            from: fromUser,
            interests: interests,
            sound: "default"
        }
    }, {
        success: function()
        {
            console.log("Invite push notification sent to " + channel)
            response.success()
            },
        error: function(error) {
            // Handle error
            console.log("Invite push notification failed: " + error)
            response.error(error)
            }
        });
    }


Parse.Cloud.define("createMatchRequest", function(request, response) {
    var Match = Parse.Object.extend("Match")
    var match = new Match()
    if (request.user == undefined) {
        response.error("User is not logged in")
        return
    }
    else {
        match.set(user, request.user)
    }
    match.set("categories", request.params.categories)

    // todo: time, location

    match.save().then(
        function(object) {
            console.log("createMatchRequest completed with match: " + object)
            response.success(object)
        },
        function(error) {
            console.log("error in createMatchRequest: " + error)
            response.error(error)
        }
    )
});

Parse.Cloud.define("queryMatches", function(request, response) {
    //var location = request.params.location // not used
    var categories = request.params.categories
 
    var query = new Parse.Query("Match")

    if (categories.length > 0) {
        categories = categories.map(toLowerCase)
        console.log("searching for " + categories.length + " categories: " + categories)
        query.containsAll("categories", categories)
    }
    query.descending("updatedAt")
    query.notEqualTo("user", request.user)

    console.log("calling query.find")
    query.find({
        success: function(matches) {
            console.log("Result matches count " + matches.length)
            response.success(matches)
        },
        error: function(error) {
            console.log("query failed: error " + error)
            response.error(error)
        }         
    })
});
