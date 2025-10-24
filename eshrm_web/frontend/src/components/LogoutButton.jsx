import React from "react";
import { useNavigate } from "react-router-dom";

export default function LogoutButton() {
    const navigate = useNavigate();

    const handleLogout = () => {
        localStorage.removeItem("token");

        navigate("/login");
    };

    return (
        <button
            onClick={handleLogout}
            style={{
                backgroundColor: "#e53935",
                color: "#fff",
                marginTop: "16px",
                padding: "0.5rem 1.2rem",
                borderRadius: "8px",
                fontWeight: "bold",
                border: "none",
                cursor: "pointer",
                transition: "0.3s",
            }}
        >
            Logout
        </button>
    );
}
