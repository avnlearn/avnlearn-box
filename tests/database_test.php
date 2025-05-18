<?php
$servername = "192.168.56.10"; // Use the static IP you set
$username = "root"; // Default username
$password = "admin@123"; // Replace with your password
$dbname = "avnlearn"; // Database name

// Create connection

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";

// Close connection
$conn->close();
