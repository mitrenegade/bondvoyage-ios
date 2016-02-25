

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
//            sendPushInviteUser(response, fromUser, toUserId, interests)
        },
        function(error) {
            console.log("Could not load user for inviting")
            response.error("Could not find user to invite")
        }     
    )
})

var sendPushForMatches = function(response, fromMatch, toMatch) {
    console.log("inside send push")
    var fromUser = fromMatch.get("user")
    var toUser = toMatch.get("user")
    console.log("from user id " + fromUser.id + " to user id " + toUser.id)
    var name = fromUser.get("firstName")
    if (name == undefined) {
        name = fromUser.get("lastName")
    }
    var categories = fromMatch.get("categories")
    var message = name + " has sent you an invitation to bond over " + categories[0]
    if (name == undefined) {
        message = "You have received an invitation to bond over " + categories[0]
    }

    var toId = toUser.id
    var channel = "channel" + toId
    console.log("push message: " + message + " channel: " + channel)
    Parse.Push.send({
        channels: [ channel ],
        data: {
            alert: message,
            from: fromUser,
            fromMatch: fromMatch,
            toMatch: toMatch,
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

var sendPushForInvitationResponse = function(response, fromMatch, toMatch, status) {
    console.log("inside send push")
    // toUser is the user who was the target of the invitation. In this case, the toUser is sending
    // the notification to the fromUser
    var fromUser = fromMatch.get("user")
    var toUser = toMatch.get("user")
    console.log("from user id " + fromUser.id + " to user id " + toUser.id)
    var name = toUser.get("firstName")
    if (name == undefined) {
        name = toUser.get("lastName")
    }
    var categories = toMatch.get("categories")
    var message = name + " has " + status + " your invitation to bond over " + categories[0]
    if (name == undefined) {
        message = "Your invitation to bond over " + categories[0] + " was " + status
    }

    var fromId = fromUser.id
    var channel = "channel" + fromId
    if (status == "cancelled") {
        // notify the invitee that the invite has been cancelled
        var toId = toUser.id
        channel = "channel" + toId
    }
    console.log("push message: " + message + " channel: " + channel)
    Parse.Push.send({
        channels: [ channel ],
        data: {
            alert: message,
            invitedUser: toUser,
            invitationStatus: status,
            fromMatch: fromMatch,
            toMatch: toMatch,
            sound: "default"
        }
    }, {
        success: function()
        {
            console.log("Invitation status push notification sent to " + channel)
            response.success()
            },
        error: function(error) {
            // Handle error
            console.log("Invitation status push notification failed: " + error)
            response.error(error)
            }
        });
    }

// MATCHES
Parse.Cloud.define("createMatchRequest", function(request, response) {
    var Match = Parse.Object.extend("Match")
    var match = new Match()
    if (request.user == undefined) {
        response.error("User is not logged in")
        return
    }
    else {
        match.set("user", request.user)
    }

    var categories = request.params.categories
    categories = categories.map(toLowerCase)
    match.set("categories", categories)
    match.set("status", "active")

    // location
    if (request.params.lat != undefined && request.params.lon != undefined) {
        var geopoint = new Parse.GeoPoint(request.params.lat, request.params.lon)
        console.log("Creating geopoint for new match at lat " + request.params.lat + " lon " + request.params.lon + " geopoint " + geopoint)
        match.set("geopoint", geopoint)
    }

    // todo: time

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

    if (categories != undefined && categories.length > 0) {
        categories = categories.map(toLowerCase)
        console.log("searching for " + categories.length + " categories: " + categories)
        query.containsAll("categories", categories)
    }
    query.descending("updatedAt")
    query.notEqualTo("user", request.user)
    query.notContainedIn("status", ["cancelled", "declined"])
    /*
    if (request.params.lat != undefined && request.params.lon != undefined) {
        var point = new Parse.GeoPoint(request.params.lat, request.params.lon)
        query.withinKilometers("geopoint", point, 5)
    }
    */

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

Parse.Cloud.define("respondToInvite", function(request, response) {
    // declined and accepted is sent by the invitee; cancelled is sent by the inviter
    var fromId = request.params.from
    var toId = request.params.to
    var responseType = request.params.responseType // "declined", "cancelled", "accepted"
    console.log("RespondToInvite from " + fromId + " to " + toId + " responseType " + responseType)
    var query = new Parse.Query("Match")
    query.get(fromId).then(
        function(fromMatch) {
            fromMatch.set("status", responseType)
            if (responseType == undefined) {
                fromMatch.set("status", "cancelled")
            }
            fromMatch.save()
            var queryTo = new Parse.Query("Match")
            queryTo.get(toId).then(
                function(toMatch) {
                    if (responseType == undefined || responseType == "cancelled" || responseType == "declined") {
                        // reset status so invitee can continue to be invited
                        toMatch.set("status", "active")
                        toMatch.unset("inviteFrom")
                    }
                    toMatch.save().then(
                        function(object) {
                            console.log("RespondToInvite completed")
                            if (responseType == undefined || responseType == "cancelled") {
                                console.log("Sending push message for " + responseType + " to match id " + toMatch.id + " from match id " + fromMatch.id)
                                sendPushForInvitationResponse(response, fromMatch, toMatch, responseType)
                            }
                            else if (responseType == "declined" || responseType == "accepted") {
                                console.log("Sending push message for " + responseType + " to match id " + toMatch.id + " from match id " + fromMatch.id)
                                sendPushForInvitationResponse(response, fromMatch, toMatch, responseType)
                            }
                            else {
                                console.log("here")
                                response.error("Invalid response type")
                            }
                        },
                        function(error) {
                            console.log("error in RespondToInvite: " + error)
                            response.error(error)
                        }
                    )
                },
                function(error) {
                    console.log("Could not load match for RespondToInvite")
                    response.error("Could not find match to respond to")
                }
            )    
        },
        function(error) {
            console.log("Could not load match for RespondToInvite")
            response.error("Could not find match to respond to")
        }
    )    
});

Parse.Cloud.define("cancelMatch", function(request, response) {
    // used for cancelling an unmatched invitation
    var matchId = request.params.match
    var query = new Parse.Query("Match")
    query.get(matchId).then(
        function(match) {
            match.set("status", "cancelled")
            match.save().then(
                function(object) {
                    console.log("cancelMatch completed with match: " + object)
                    response.success(object)
                },
                function(error) {
                    console.log("error in cancelMatch: " + error)
                    response.error(error)
                }
            )
        },
        function(error) {
            console.log("Could not load match for cancelling")
            response.error("Could not find match to cancel")
        }     
    )    
});

Parse.Cloud.define("inviteMatch", function(request, response) {
    var fromUser = request.user
    var fromMatchId = request.params.from
    var toMatchId = request.params.to

    var query = new Parse.Query("Match")
    query.get(fromMatchId).then(
        function (fromMatch) {
            var query = new Parse.Query("Match")
            query.get(toMatchId).then(
                function (toMatch) {
                    fromMatch.set("status", "pending")
                    fromMatch.set("inviteTo", toMatch)
                    toMatch.set("status", "pending")
                    toMatch.set("inviteFrom", fromMatch)     
                    fromMatch.save()
                    toMatch.save()

                    console.log("Sending push message to match id " + toMatch.id + " from match id " + fromMatch.id)
                    sendPushForMatches(response, fromMatch, toMatch)
                },
                function(error) {
                    console.log("Could not load match for connecting")
                    response.error("Could not load your match request")
                }     
            )
        },
        function(error) {
            console.log("Could not load match for connecting")
            response.error("Could not load your match request")
        }  
    )
});

//******************* V2 Activities
Parse.Cloud.define("createActivity", function(request, response) {
    var Activity = Parse.Object.extend("Activity")
    var activity = new Activity()
    if (request.user == undefined) {
        response.error("User is not logged in")
        return
    }
    else {
        activity.set("user", request.user)
    }

    var categories = request.params.categories
    categories = categories.map(toLowerCase)
    activity.set("categories", categories)
    activity.set("status", "active")

    // location
    if (request.params.lat != undefined && request.params.lon != undefined) {
        var geopoint = new Parse.GeoPoint(request.params.lat, request.params.lon)
        console.log("Creating geopoint for new activity at lat " + request.params.lat + " lon " + request.params.lon + " geopoint " + geopoint)
        activity.set("geopoint", geopoint)
    }

    // todo: time

    activity.save().then(
        function(object) {
            console.log("createActivity completed with activity: " + object)
            response.success(object)
        },
        function(error) {
            console.log("error in createActivity: " + error)
            response.error(error)
        }
    )
});

Parse.Cloud.define("queryActivities", function(request, response) {
    //var location = request.params.location // not used
    var categories = request.params.categories
    var userId = request.params.userId

    var query = new Parse.Query("Activity")

    if (categories != undefined && categories.length > 0) {
        categories = categories.map(toLowerCase)
        console.log("searching for " + categories.length + " categories: " + categories)
        query.containsAll("categories", categories)
    }
    query.descending("updatedAt")
    /*
    if (request.params.lat != undefined && request.params.lon != undefined) {
        var point = new Parse.GeoPoint(request.params.lat, request.params.lon)
        query.withinKilometers("geopoint", point, 5)
    }
    */

    if (userId == undefined) {
        // find all activities that do not belong to current user
        query.notEqualTo("user", request.user)
        query.notContainedIn("status", ["cancelled", "declined", "pending"])
        console.log("calling query.find")
        query.find({
            success: function(results) {
                console.log("Result count " + results.length)
                response.success(results)
            },
            error: function(error) {
                console.log("query failed: error " + error)
                response.error(error)
            }         
        })
    }
    else {
        // find all activities that belong to a specified user
        var userQuery = new Parse.Query(Parse.User)
        userQuery.get(userId, {
            success: function(user){
                console.log("calling query.find")
                query.equalTo("user", user)
                query.notContainedIn("status", ["cancelled", "declined"])
                query.find({
                    success: function(results) {
                        console.log("Result count " + results.length)
                        response.success(results)
                    },
                    error: function(error) {
                        console.log("query failed: error " + error)
                        response.error(error)
                    }         
                })
            },
            error: function(error) {
                console.log("query failed: error " + error)
                response.error(error)
            }
        })
    }
});

Parse.Cloud.define("joinActivity", function(request, response) {
    var fromUser = request.user
    var activityId = request.params.activity
    var placeId = request.params.place

    var query = new Parse.Query("Activity")
    query.get(activityId).then(
        function(activity) {
            activity.set("status", "pending")
            activity.save()

            // add user to list of joiners
            activity.addUnique("joining", fromUser.id)
            var userPlace = {}
            userPlace[fromUser.id] = placeId
            activity.addUnique("places", userPlace)
            activity.save().then(
                function(object) {
                    console.log("Sending push message to activity id " + activity.id)
                    sendPushForActivities(response, activity, fromUser)
                }, function(error) {
                    console.log("Could not save activity for connecting")
                    response.error("Could not join activity")
                }
            )
        },
        function(error) {
            console.log("Could not load activity for connecting")
            response.error("Could not find the activity to join")
        }  
    )
});

Parse.Cloud.define("cancelActivity", function(request, response) {
    // used for cancelling an unmatched invitation
    var activityId = request.params.activity
    var query = new Parse.Query("Activity")
    query.get(activityId).then(
        function(activity) {
            activity.set("status", "cancelled")
            activity.save().then(
                function(object) {
                    console.log("cancelActivity completed with result: " + object)
                    response.success(object)
                },
                function(error) {
                    console.log("error in cancelActivity: " + error)
                    response.error(error)
                }
            )
        },
        function(error) {
            console.log("Could not load activity for cancelling")
            response.error("Could not find activity to cancel")
        }     
    )    
});

Parse.Cloud.define("respondToJoin", function(request, response) {
    // TODO: implement

    // declined and accepted is sent by the invitee; cancelled is sent by the inviter
    var fromId = request.params.from
    var toId = request.params.to
    var responseType = request.params.responseType // "declined", "cancelled", "accepted"
    console.log("RespondToInvite from " + fromId + " to " + toId + " responseType " + responseType)
    var query = new Parse.Query("Match")
    query.get(fromId).then(
        function(fromMatch) {
            fromMatch.set("status", responseType)
            if (responseType == undefined) {
                fromMatch.set("status", "cancelled")
            }
            fromMatch.save()
            var queryTo = new Parse.Query("Match")
            queryTo.get(toId).then(
                function(toMatch) {
                    if (responseType == undefined || responseType == "cancelled" || responseType == "declined") {
                        // reset status so invitee can continue to be invited
                        toMatch.set("status", "active")
                        toMatch.unset("inviteFrom")
                    }
                    toMatch.save().then(
                        function(object) {
                            console.log("RespondToInvite completed")
                            if (responseType == undefined || responseType == "cancelled") {
                                console.log("Sending push message for " + responseType + " to match id " + toMatch.id + " from match id " + fromMatch.id)
                                sendPushForInvitationResponse(response, fromMatch, toMatch, responseType)
                            }
                            else if (responseType == "declined" || responseType == "accepted") {
                                console.log("Sending push message for " + responseType + " to match id " + toMatch.id + " from match id " + fromMatch.id)
                                sendPushForInvitationResponse(response, fromMatch, toMatch, responseType)
                            }
                            else {
                                console.log("here")
                                response.error("Invalid response type")
                            }
                        },
                        function(error) {
                            console.log("error in RespondToInvite: " + error)
                            response.error(error)
                        }
                    )
                },
                function(error) {
                    console.log("Could not load match for RespondToInvite")
                    response.error("Could not find match to respond to")
                }
            )    
        },
        function(error) {
            console.log("Could not load match for RespondToInvite")
            response.error("Could not find match to respond to")
        }
    )    
});

var sendPushForActivities = function(response, activity, fromUser) {
    console.log("inside send push")
    var toUser = activity.get("user")
    console.log("from user id " + fromUser.id + " to user id " + toUser.id)
    var name = fromUser.get("firstName")
    if (name == undefined) {
        name = fromUser.get("lastName")
    }
    var categories = activity.get("categories")
    var message = name + " has sent you an invitation to bond over " + categories[0]
    if (name == undefined) {
        message = "You have received an invitation to bond over " + categories[0]
    }

    var toId = toUser.id
    var channel = "channel" + toId
    console.log("push message: " + message + " channel: " + channel)
    Parse.Push.send({
        channels: [ channel ],
        data: {
            alert: message,
            from: fromUser,
            activity: activity,
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

