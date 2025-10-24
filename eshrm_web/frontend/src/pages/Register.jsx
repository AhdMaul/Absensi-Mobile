import React, { useState } from "react";
import API from "../api";
import FastAPI from "../fastapi";
import { useNavigate } from "react-router-dom";

export default function RegisterWithFace() {
    const [name, setName] = useState("");
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [files, setFiles] = useState([]);
    const [previewUrls, setPreviewUrls] = useState([]);
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    const handleFilesChange = (e) => {
        const selectedFiles = Array.from(e.target.files);
        setFiles(selectedFiles);
        setPreviewUrls(selectedFiles.map((file) => URL.createObjectURL(file)));
    };

    const handleRegister = async (e) => {
        e.preventDefault();
        if (files.length === 0) {
            alert("Silakan pilih minimal satu foto wajah");
            return;
        }

        try {
            setLoading(true);

            await API.post("/auth/register", { name, email, password });

            const loginRes = await API.post("/auth/login", { email, password });
            const token = loginRes.data.token;

            const formData = new FormData();
            for (let file of files) {
                formData.append("images", file);
            }
            const resFace = await FastAPI.post("/register", formData, {
                headers: {
                    "Content-Type": "multipart/form-data",
                    Authorization: `Bearer ${token}`,
                },
            });

            alert(
                `${resFace.data.message}\n${resFace.data.train_result?.message || ""}`
            );
            navigate("/login");
        } catch (err) {
            console.error(err);
            alert(err.response?.data?.message || "Gagal mendaftar akun/wajah");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-gray-100 dark:from-gray-900 dark:to-gray-950 px-4 sm:px-6 lg:px-8 transition-colors duration-300">
            <div className="w-full max-w-md sm:max-w-lg md:max-w-md lg:max-w-lg xl:max-w-xl bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-6 sm:p-8 md:p-10">
                <h2 className="text-2xl sm:text-3xl font-extrabold text-center text-gray-800 dark:text-white mb-6">
                    Register
                </h2>

                <form onSubmit={handleRegister} className="space-y-5">
                    {/* Nama */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                            Nama
                        </label>
                        <input
                            type="text"
                            placeholder="Nama"
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                            required
                            className="w-full px-4 py-2 sm:py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-gray-100 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition"
                        />
                    </div>

                    {/* Email */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                            Email
                        </label>
                        <input
                            type="email"
                            placeholder="contoh@email.com"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            required
                            className="w-full px-4 py-2 sm:py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-gray-100 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition"
                        />
                    </div>

                    {/* Password */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                            Password
                        </label>
                        <input
                            type="password"
                            placeholder="••••••••"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                            className="w-full px-4 py-2 sm:py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-800 dark:text-gray-100 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition"
                        />
                    </div>

                    {/* Foto wajah */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                            Foto Wajah
                        </label>
                        <input
                            type="file"
                            multiple
                            accept="image/*"
                            onChange={handleFilesChange}
                            required
                            className="block w-full text-sm text-gray-600 dark:text-gray-300
                                file:mr-4 file:py-2 file:px-4
                                file:rounded-lg file:border-0
                                file:text-sm file:font-semibold
                                file:bg-blue-50 dark:file:bg-gray-700 
                                file:text-blue-600 dark:file:text-blue-400
                                hover:file:bg-blue-100 dark:hover:file:bg-gray-600
                            "
                        />

                        {previewUrls.length > 0 && (
                            <div className="grid grid-cols-3 gap-3 mt-3">
                                {previewUrls.map((url, i) => (
                                    <img
                                        key={i}
                                        src={url}
                                        alt="preview"
                                        className="w-full h-24 object-cover rounded-lg border dark:border-gray-600"
                                    />
                                ))}
                            </div>
                        )}
                    </div>

                    {/* Submit */}
                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full py-2.5 sm:py-3 bg-white text-black dark:bg-gray-800 dark:text-white font-semibold rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 active:scale-95 transition-transform duration-150 disabled:opacity-60"
                    >
                        {loading ? "Processing..." : "Register & Upload Face"}
                    </button>
                </form>

                <p className="text-center text-sm sm:text-base text-gray-600 dark:text-gray-400 mt-6">
                    Sudah punya akun?{" "}
                    <a
                        href="/login"
                        className="text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 font-medium underline-offset-2 hover:underline transition"
                    >
                        Login
                    </a>
                </p>
            </div>
        </div>
    );
}
