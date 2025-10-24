import React from "react";

export default function Home() {
    return (
        <div style={styles.page}>
            {/* Navbar */}
            <nav style={styles.navbar}>
                <div style={styles.logo}>Face Recognition</div>
                <div>
                    <a href="/login" style={styles.loginButton}>Login</a>
                </div>
            </nav>

            {/* Hero Section */}
            <div style={styles.hero}>
                <h1 style={styles.title}>Selamat Datang</h1>
                <p style={styles.subtitle}>Sistem Pengenalan Wajah yang Canggih & Aman</p>
                <a href="/login" style={styles.ctaButton}>Mulai Sekarang</a>
            </div>

            {/* Footer */}
            <footer style={styles.footer}>
                &copy; {new Date().getFullYear()} CNPLUS. All rights reserved.
            </footer>
        </div>
    );
}

const styles = {
    page: {
        fontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif",
        backgroundColor: "#121212",
        color: "#fff",
        minHeight: "100vh",
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
    },
    navbar: {
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        padding: "1rem 2rem",
        backgroundColor: "#1f1f1f",
        borderBottom: "1px solid #333",
        position: "sticky",
        top: 0,
        zIndex: 1000,
    },
    logo: {
        fontSize: "1.5rem",
        fontWeight: "bold",
        color: "#6200ee",
    },
    loginButton: {
        backgroundColor: "#6200ee",
        color: "#fff",
        padding: "0.5rem 1.2rem",
        borderRadius: "8px",
        textDecoration: "none",
        fontWeight: "bold",
        transition: "0.3s",
    },
    hero: {
        textAlign: "center",
        padding: "4rem 2rem",
        flexGrow: 1,
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
        alignItems: "center",
    },
    title: {
        fontSize: "2.5rem",
        marginBottom: "1rem",
        animation: "fadeIn 1.2s ease-in-out",
    },
    subtitle: {
        fontSize: "1.2rem",
        marginBottom: "2rem",
        color: "#bbb",
    },
    ctaButton: {
        backgroundColor: "#03dac6",
        color: "#000",
        padding: "0.7rem 1.5rem",
        borderRadius: "8px",
        textDecoration: "none",
        fontWeight: "bold",
        transition: "0.3s",
    },
    footer: {
        textAlign: "center",
        padding: "1rem 0",
        backgroundColor: "#1f1f1f",
        borderTop: "1px solid #333",
        fontSize: "0.9rem",
        color: "#888",
    },
    '@media(maxWidth: 768px)': {
        title: {
            fontSize: "2rem",
        },
        subtitle: {
            fontSize: "1rem",
        },
        navbar: {
            flexDirection: "column",
            gap: "0.5rem",
        },
    },
};
