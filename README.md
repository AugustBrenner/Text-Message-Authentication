Text-Message-Authentication
===========================

text message authentication for iOS applications.

It is way over built and thus buggy. I wanted to Use Core Data, even though complete server side authentication
is most advisable for a scinereo like this.  The server authenticates and stores values in core data which it polls
for user authenticaiton. It prompts for your phone number, sends a text message with a confirmation code which is entered
tieing the phone number to the phone in a way allowed by apple.  It also prompts to pull user contacts requeting
permission from the client.  All Information is stored in mySQL database.
