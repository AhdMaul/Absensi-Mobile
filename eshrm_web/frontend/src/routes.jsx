import React from "react";
import { Routes, Route, Navigate, useLocation } from "react-router-dom";
import Login from "./pages/Login";
import Register from "./pages/Register";
import FaceVerify from "./pages/FaceVerify";
import FaceRegister from "./pages/FaceRegister";
import FaceVerifyBlinkAuto from "./pages/FaceBlink";
import Home from "./pages/Home";


const PrivateRoute = ({ children }) => {
    const token = localStorage.getItem('token');
    return token ? children : <Navigate to="/login" replace />;
};

const RedirectIfAuthenticated = ({ children }) => {
    const token = localStorage.getItem('token');
    return token ? <Navigate to="/verify" replace /> : children;
};

const AppRoutes = () => {

    const location = useLocation();

    return (
        <Routes location={location} key={location.pathname}>
            <Route path="/" element={<Home />} />
            <Route path="/register" element={<RedirectIfAuthenticated><Register /></RedirectIfAuthenticated>} />
            <Route path="/login" element={<RedirectIfAuthenticated><Login /></RedirectIfAuthenticated>} />


            <Route path="/verify" element={<PrivateRoute><FaceVerify /></PrivateRoute>} />
            <Route path="/verify-blink" element={<PrivateRoute><FaceVerifyBlinkAuto /></PrivateRoute>} />
            <Route path="/face" element={<PrivateRoute><FaceRegister /></PrivateRoute>} />
            {/* <Route path="*" element={<NotFoundPage />} /> */}
        </Routes>


    );
}

export default AppRoutes;

