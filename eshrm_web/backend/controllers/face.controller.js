import axios from "axios";
import { LBPH_URL } from "../config/env.js";

export const verify = async (req, res) => {
    try {
        const { image } = req.body;
        const token = req.headers.authorization; 
        if (!image) {
            return res.status(400).json({ message: "Gambar tidak ditemukan." });
        }

        console.log(`Meneruskan permintaan verifikasi ke FastAPI di ${LBPH_URL}...`);

        const formData = new URLSearchParams();
        formData.append('image_base64', image);

        const fastApiResponse = await axios.post(LBPH_URL, formData, {
            headers: {
                'Authorization': token,
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        });

        res.status(fastApiResponse.status).json(fastApiResponse.data);

    } catch (error) {
        console.error("Error saat memanggil FastAPI:", error.message);

        if (error.response) {
            return res.status(error.response.status).json(error.response.data);
        }

        res.status(500).json({ message: "Terjadi kesalahan internal di server Express." });
    }
}