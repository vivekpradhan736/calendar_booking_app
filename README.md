# Calendar Booking System

## Overview

The **Calendar Booking System** is a web application built with a Flutter frontend and a Node.js backend, designed to manage meeting bookings. Users can create, update, view, and delete bookings on a calendar interface. The app includes features like overlap detection to prevent conflicting bookings and toast notifications for user feedback.

- **Frontend**: Flutter (compiled to a web app)  
- **Backend**: Node.js with Express  
- **Storage**: In-memory (recommended to switch to a database like MongoDB for production)  
- **Deployment**: Backend on Render, Frontend on Firebase Hosting  

This project was completed on May 14, 2025.

## Features

- **Interactive Calendar**: View and manage bookings using a calendar interface.
- **Booking Management**: Create, update, and delete bookings with user-friendly dialogs.
- **Overlap Detection**: Prevents scheduling conflicts by checking for overlapping bookings.
- **Toast Notifications**: Displays success, error, and warning messages using Fluttertoast.
- **Error Handling**: Robust error handling for network issues, timeouts, and invalid inputs.
- **Production-Ready**: Optimized for deployment with security headers, compression, and CORS support.

## Prerequisites

Before setting up the project, ensure you have the following installed:

### General

- **Git**: To clone the repository.
- **Node.js and npm**: Version 14.x or higher (for the backend).
- **Flutter**: Version 3.x or higher (for the frontend).
- **Dart**: Comes with Flutter.
- **A code editor**: VS Code, Android Studio, or IntelliJ IDEA recommended.

### For Deployment

- **Render Account**: For deploying the Node.js backend ([render.com](https://render.com)).
- **Firebase Account**: For deploying the Flutter web app ([firebase.google.com](https://firebase.google.com)).
- **Firebase CLI**: For deploying to Firebase Hosting (`npm install -g firebase-tools`).

## Setup Instructions

### 1. Clone the Repository

Clone the project to your local machine:


Frontend Code :- git clone https://github.com/vivekpradhan736/calendar_booking_app.git

Backend Code :- git clone https://github.com/vivekpradhan736/calendar_booking_app_backend.git


### 2. Set Up the Backend
#### Navigate to the backend directory and install dependencies:
cd backend
npm install

#### Run the Backend Locally
Start the Node.js server:
node server.js

The backend will run on http://localhost:3000. Test it by accessing http://localhost:3000/bookings in a browser or using a tool like Postman (you should see an empty array [] initially).
#### (Optional) Set Up a Database
The current backend uses an in-memory array for storage, which is not suitable for production. To use MongoDB:

Install the MongoDB driver:

npm install mongodb


Sign up for MongoDB Atlas at [mongodb.com](https://mongodb.com/) and create a cluster.
Get your MongoDB connection string (e.g., mongodb+srv://&lt;username&gt;:&lt;password&gt;@cluster0.mongodb.net/bookings?retryWrites=true&amp;w=majority).
Update server.js to connect to MongoDB (see the deployment section for a code snippet).
Set the MONGODB_URI environment variable (see deployment instructions).


### 3. Set Up the Frontend
#### Navigate to the calendar_booking_app directory:
cd ../calendar_booking_app

#### Install Flutter Dependencies
Install the required Flutter packages:
flutter pub get

#### Enable Web Support
Ensure Flutter web support is enabled:
flutter config --enable-web

#### Run the Frontend Locally
Run the Flutter app on a web browser:
flutter run -d chrome

The app will open in your default browser (e.g., Chrome) and connect to the backend at http://localhost:3000. If you’ve deployed the backend, update the _baseUrl in lib/main.dart to point to your deployed backend URL (see deployment instructions below).

## Usage
### Open the App
Access the app in your browser (locally at http://localhost:4200 or the deployed URL).
### View the Calendar
The calendar displays bookings as markers on specific dates.
### Create a Booking

Click the "New Booking" button.
Fill in the User ID, Title, Start Date/Time, End Date/Time, and optional Description.
Click "Create Booking".
A green toast notification will confirm success, or a red/orange toast will show errors (e.g., overlapping bookings).

### View Bookings
Click on a date to see all bookings for that day in a dialog.
### Update a Booking
In the bookings dialog, click the edit icon (blue pencil) for a booking, update the details, and click "Update Booking".
### Delete a Booking
In the bookings dialog, click the delete icon (red trash) to remove a booking.

## Deployment Instructions
### Deploy the Backend to Render
#### Push to GitHub

Create a GitHub repository for the backend folder.
Push the code:

cd backend
git init
git add .
git commit -m "Initial commit"
git remote add origin &lt;your-backend-repo-url&gt;
git push -u origin main

#### Create a Render Web Service

Sign up at [render.com](https://render.com/).
Create a new Web Service and connect your GitHub repository.
Configure the service:
Environment: Node
Build Command: npm install
Start Command: node server.js
Instance Type: Free (for testing; upgrade for production)


(Optional) If using MongoDB, add an environment variable:
Key: MONGODB_URI
Value: Your MongoDB connection string


Deploy the app.

#### Get the Backend URL
Render will provide a URL (e.g., https://your-app-name.onrender.com). Test it:
curl https://your-app-name.onrender.com/bookings

### Deploy the Frontend to Firebase Hosting
#### Update the Backend URL
In lib/main.dart, update the _baseUrl to your Render backend URL:
final String _baseUrl = 'https://your-app-name.onrender.com';

#### Build the Flutter Web App
flutter build web --release

#### Install Firebase CLI
npm install -g firebase-tools

#### Log in to Firebase
firebase login

#### Initialize Firebase Hosting
firebase init hosting


Select your Firebase project.
Set the public directory to build/web.
Configure as a single-page app (answer y and set index.html).

#### Deploy to Firebase
firebase deploy

Access your app at the provided URL (e.g., https://your-project-name.web.app).

## Secure the App
### CORS
In server.js, restrict CORS to your frontend URL:
app.use(cors({
  origin: 'https://your-project-name.web.app'
}));

### HTTPS
Both Render and Firebase Hosting use HTTPS by default.
### Authentication
Consider adding authentication (e.g., Firebase Authentication or JWT) to secure your API.

## Troubleshooting
### Backend Not Responding

Check Render logs for errors.
Ensure the backend URL is correct in main.dart.
Verify CORS settings if the frontend can’t connect.

### Frontend Not Loading

Check Firebase Hosting deployment logs.
Ensure the _baseUrl in main.dart matches your backend URL.
Clear browser cache if the app doesn’t update after deployment.

### Network Errors

Ensure both the backend and frontend are using HTTPS.
Check your internet connection.
Verify the backend server is running (e.g., on Render).

### Overlapping Bookings Not Detected

Ensure the hasOverlap function in server.js is working correctly.
Check the date formats in your requests (must be ISO 8601).


## Future Improvements

Database Integration: Replace the in-memory storage with a database like MongoDB or PostgreSQL.
Authentication: Add user authentication to secure the app.
Notifications: Implement email or push notifications for booking confirmations.
Testing: Add unit and integration tests for both frontend and backend.
Monitoring: Integrate error tracking (e.g., Sentry) and analytics (e.g., Firebase Analytics).


## License
This project is licensed under the MIT License. See the LICENSE file for details.
# Calendar Booking System

## Overview

The **Calendar Booking System** is a web application built with a Flutter frontend and a Node.js backend, designed to manage meeting bookings. Users can create, update, view, and delete bookings on a calendar interface. The app includes features like overlap detection to prevent conflicting bookings and toast notifications for user feedback.

- **Frontend**: Flutter (compiled to a web app)  
- **Backend**: Node.js with Express  
- **Storage**: In-memory (recommended to switch to a database like MongoDB for production)  
- **Deployment**: Backend on Render, Frontend on Firebase Hosting  

This project was completed on May 14, 2025.

## Features

- **Interactive Calendar**: View and manage bookings using a calendar interface.
- **Booking Management**: Create, update, and delete bookings with user-friendly dialogs.
- **Overlap Detection**: Prevents scheduling conflicts by checking for overlapping bookings.
- **Toast Notifications**: Displays success, error, and warning messages using Fluttertoast.
- **Error Handling**: Robust error handling for network issues, timeouts, and invalid inputs.
- **Production-Ready**: Optimized for deployment with security headers, compression, and CORS support.

## Prerequisites

Before setting up the project, ensure you have the following installed:

### General

- **Git**: To clone the repository.
- **Node.js and npm**: Version 14.x or higher (for the backend).
- **Flutter**: Version 3.x or higher (for the frontend).
- **Dart**: Comes with Flutter.
- **A code editor**: VS Code, Android Studio, or IntelliJ IDEA recommended.

### For Deployment

- **Render Account**: For deploying the Node.js backend ([render.com](https://render.com)).
- **Firebase Account**: For deploying the Flutter web app ([firebase.google.com](https://firebase.google.com)).
- **Firebase CLI**: For deploying to Firebase Hosting (`npm install -g firebase-tools`).

## Setup Instructions

### 1. Clone the Repository

Clone the project to your local machine:


Frontend Code :- git clone https://github.com/vivekpradhan736/calendar_booking_app.git

Backend Code :- git clone https://github.com/vivekpradhan736/calendar_booking_app_backend.git


### 2. Set Up the Backend
#### Navigate to the backend directory and install dependencies:
cd backend
npm install

#### Run the Backend Locally
Start the Node.js server:
node server.js

The backend will run on http://localhost:3000. Test it by accessing http://localhost:3000/bookings in a browser or using a tool like Postman (you should see an empty array [] initially).
#### (Optional) Set Up a Database
The current backend uses an in-memory array for storage, which is not suitable for production. To use MongoDB:

Install the MongoDB driver:

npm install mongodb


Sign up for MongoDB Atlas at [mongodb.com](https://mongodb.com/) and create a cluster.
Get your MongoDB connection string (e.g., mongodb+srv://&lt;username&gt;:&lt;password&gt;@cluster0.mongodb.net/bookings?retryWrites=true&amp;w=majority).
Update server.js to connect to MongoDB (see the deployment section for a code snippet).
Set the MONGODB_URI environment variable (see deployment instructions).


### 3. Set Up the Frontend
#### Navigate to the calendar_booking_app directory:
cd ../calendar_booking_app

#### Install Flutter Dependencies
Install the required Flutter packages:
flutter pub get

#### Enable Web Support
Ensure Flutter web support is enabled:
flutter config --enable-web

#### Run the Frontend Locally
Run the Flutter app on a web browser:
flutter run -d chrome

The app will open in your default browser (e.g., Chrome) and connect to the backend at http://localhost:3000. If you’ve deployed the backend, update the _baseUrl in lib/main.dart to point to your deployed backend URL (see deployment instructions below).

## Usage
### Open the App
Access the app in your browser (locally at http://localhost:4200 or the deployed URL).
### View the Calendar
The calendar displays bookings as markers on specific dates.
### Create a Booking

Click the "New Booking" button.
Fill in the User ID, Title, Start Date/Time, End Date/Time, and optional Description.
Click "Create Booking".
A green toast notification will confirm success, or a red/orange toast will show errors (e.g., overlapping bookings).

### View Bookings
Click on a date to see all bookings for that day in a dialog.
### Update a Booking
In the bookings dialog, click the edit icon (blue pencil) for a booking, update the details, and click "Update Booking".
### Delete a Booking
In the bookings dialog, click the delete icon (red trash) to remove a booking.

## Deployment Instructions
### Deploy the Backend to Render
#### Push to GitHub

Create a GitHub repository for the backend folder.
Push the code:

cd backend
git init
git add .
git commit -m "Initial commit"
git remote add origin &lt;your-backend-repo-url&gt;
git push -u origin main

#### Create a Render Web Service

Sign up at [render.com](https://render.com/).
Create a new Web Service and connect your GitHub repository.
Configure the service:
Environment: Node
Build Command: npm install
Start Command: node server.js
Instance Type: Free (for testing; upgrade for production)


(Optional) If using MongoDB, add an environment variable:
Key: MONGODB_URI
Value: Your MongoDB connection string


Deploy the app.

#### Get the Backend URL
Render will provide a URL (e.g., https://your-app-name.onrender.com). Test it:
curl https://your-app-name.onrender.com/bookings

### Deploy the Frontend to Firebase Hosting
#### Update the Backend URL
In lib/main.dart, update the _baseUrl to your Render backend URL:
final String _baseUrl = 'https://your-app-name.onrender.com';

#### Build the Flutter Web App
flutter build web --release

#### Install Firebase CLI
npm install -g firebase-tools

#### Log in to Firebase
firebase login

#### Initialize Firebase Hosting
firebase init hosting


Select your Firebase project.
Set the public directory to build/web.
Configure as a single-page app (answer y and set index.html).

#### Deploy to Firebase
firebase deploy

Access your app at the provided URL (e.g., https://your-project-name.web.app).

## Secure the App
### CORS
In server.js, restrict CORS to your frontend URL:
app.use(cors({
  origin: 'https://your-project-name.web.app'
}));

### HTTPS
Both Render and Firebase Hosting use HTTPS by default.
### Authentication
Consider adding authentication (e.g., Firebase Authentication or JWT) to secure your API.

## Troubleshooting
### Backend Not Responding

Check Render logs for errors.
Ensure the backend URL is correct in main.dart.
Verify CORS settings if the frontend can’t connect.

### Frontend Not Loading

Check Firebase Hosting deployment logs.
Ensure the _baseUrl in main.dart matches your backend URL.
Clear browser cache if the app doesn’t update after deployment.

### Network Errors

Ensure both the backend and frontend are using HTTPS.
Check your internet connection.
Verify the backend server is running (e.g., on Render).

### Overlapping Bookings Not Detected

Ensure the hasOverlap function in server.js is working correctly.
Check the date formats in your requests (must be ISO 8601).


## Future Improvements

Database Integration: Replace the in-memory storage with a database like MongoDB or PostgreSQL.
Authentication: Add user authentication to secure the app.
Notifications: Implement email or push notifications for booking confirmations.
Testing: Add unit and integration tests for both frontend and backend.
Monitoring: Integrate error tracking (e.g., Sentry) and analytics (e.g., Firebase Analytics).


## License
This project is licensed under the MIT License. See the LICENSE file for details.
