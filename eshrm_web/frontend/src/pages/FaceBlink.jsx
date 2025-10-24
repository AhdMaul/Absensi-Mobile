import { useRef, useEffect, useState } from "react";
import API from "../fastapi";

export default function FaceVerifyBlinkAuto() {
    const videoRef = useRef(null);
    const mediaRecorderRef = useRef(null);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        const startRecording = async () => {
            try {
                setLoading(true);
                const stream = await navigator.mediaDevices.getUserMedia({ video: true });
                videoRef.current.srcObject = stream;

                const recorder = new MediaRecorder(stream);
                let chunks = [];

                recorder.ondataavailable = (e) => {
                    if (e.data.size > 0) {
                        chunks.push(e.data);
                    }
                };

                recorder.onstop = async () => {
                    const blob = new Blob(chunks, { type: "video/mp4" });
                    chunks = [];
                    await sendVideo(blob);

                    stream.getTracks().forEach(track => track.stop());
                };

                recorder.start();
                mediaRecorderRef.current = recorder;

                setTimeout(() => recorder.stop(), 3000);

            } catch (err) {
                console.error("Gagal mengakses kamera", err);
                setLoading(false);
            }
        };

        startRecording();
    }, []);

    const sendVideo = async (videoBlob) => {
        const formData = new FormData();
        formData.append("video", videoBlob, "verify.mp4");

        try {
            const res = await API.post("/verify-blink", formData, {
                headers: { "Content-Type": "multipart/form-data" },
            });
            alert(res.data.message);
        } catch (err) {
            console.error(err);
            alert("Verifikasi gagal");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div>
            <h2>Verifikasi Wajah (Kedip Otomatis)</h2>
            <video ref={videoRef} autoPlay playsInline style={{ width: "300px" }} />
            {loading && <p>Memproses verifikasi...</p>}
        </div>
    );
}
