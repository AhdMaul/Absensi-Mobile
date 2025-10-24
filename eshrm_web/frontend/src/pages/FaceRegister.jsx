import { useState } from "react";
import API from "../fastapi";

export default function FaceRegister() {
    const [files, setFiles] = useState([]);

    const handleFilesChange = (e) => setFiles(e.target.files);

    const handleRegisterFace = async () => {
        const formData = new FormData();
        for (let file of files) {
            formData.append("images", file);
        }

        try {
            const res = await API.post("/register", formData, {
                headers: { "Content-Type": "multipart/form-data" },
            });
            console.log(res.data);
            alert(`${res.data.message}\n${res.data.train_result?.message || ""}`);
        } catch (err) {
            console.error(err);
            alert("Gagal mendaftar wajah");
        }
    };

    return (
        <div>
            <input type="file" multiple accept="image/*" onChange={handleFilesChange} />
            <button onClick={handleRegisterFace}>Daftar Muka</button>
        </div>
    );

}