# Pocket Book - App Walkthrough Script (Target: ~90-100 Seconds)

---

**(Intro - ~5-10 seconds)**

Hi, this is a walkthrough of my Flutter application, 'Pocket Book,' developed for the Coding Mind Academy Bootstrap assignment. Pocket Book is a simple personal finance tracker that helps users manage their income and expenses.

---

**(Registration - ~15 seconds)**

First, let's register a new user. 
*(Show Registration Screen)* 
I'll enter an email and a password. 
*(Enter details)* 
The app uses Firebase Authentication for user management. 
*(Click 'Register')* 
Upon successful registration, a user profile is also created in the Firebase Realtime Database.

---

**(Login & App Scaffold - ~10 seconds)**

Now, if I log out and log back in with the same credentials... 
*(Quickly show logging out if it's easy, or just go to Login screen)*. 
*(Show Login Screen, enter details, click 'Login')* 
...the app remembers the user and takes us to the main interface. This is the `AppScaffold` which uses a `BottomNavigationBar` for navigation between Overview, Add Entry, and History.

---

**(Adding Transactions - ~25 seconds)**

Let's go to the 'Add Entry' screen. 
*(Navigate to Add Entry screen)* 
Here, I can log an income or an expense. I'll add an income, say 'Salary' of \$2000. 
*(Fill form, select category, select 'Income' type, click 'Add Entry')*. 
And now, let's add an expense for 'Groceries' of \$75. 
*(Fill form, select category, 'Expense' type is default, click 'Add Entry')*. 
All transactions are stored in the Firebase Realtime Database under the current user's ID.

---

**(Overview Screen - ~15-20 seconds)**

Back on the 'Overview' screen, 
*(Navigate to Overview screen)* 
we can see the data has updated. 
*(Point to totals and pie chart)* 
It shows the total income and expenses for the current month, along with a pie chart. Below, we see a summary of spending by category. This screen listens for real-time updates from Firebase.

---

**(History Screen - ~10-15 seconds)**

The 'History' screen 
*(Navigate to History screen)* 
displays all transactions, with the newest ones first. 
*(Scroll a bit if there are a few entries)* 
We can see the 'Salary' and 'Groceries' entries we just added. Each item shows the category, amount, type, and date.

---

**(Logout - ~5 seconds)**

Finally, users can log out from the app. 
*(Click logout icon)* 
This takes them back to the login screen, and Firebase Auth handles the session termination.

---

**(Firebase Console (Optional Quick Flash) - ~5 seconds - ONLY IF SMOOTH)**

*(If you can transition very quickly)* 
And here's a quick look at the Firebase console, showing the authenticated user and the data stored in the Realtime Database. 
*(Briefly show user in Auth tab and data in RTDB)*

---

**(Outro - ~5 seconds)**

This demonstrates the core features of Pocket Book, integrating Flutter with Firebase Authentication and Realtime Database. Thank you!

---
