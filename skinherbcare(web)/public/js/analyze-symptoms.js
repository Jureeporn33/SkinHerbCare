document.addEventListener('DOMContentLoaded', () => {
    const analyzeBtn = document.getElementById('analyze-symptom-btn');
    const resultsContainer = document.getElementById('results-container');
    const textInput = document.getElementById('symptom-input');

    analyzeBtn.addEventListener('click', async () => {
        const symptoms = textInput.value.trim();

        if (symptoms === '') {
            alert('กรุณากรอกอาการของคุณก่อน');
            return;
        }

        // Show loading state
        analyzeBtn.disabled = true;
        analyzeBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i> กำลังวิเคราะห์...';
        resultsContainer.innerHTML = '<p class="text-gray-500 text-center">กำลังปรึกษา AI... กรุณารอสักครู่ (อาจใช้เวลา 5-10 วินาที)</p>';

        try {
            const res = await fetch('/api/gemini/suggest-herbs', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ symptoms })
            });

            const data = await res.json();

            if (data.success) {
                // แสดงผลลัพธ์จาก AI
                let htmlContent = '<h4 class="text-xl font-bold mb-4 text-green-800">สมุนไพรที่แนะนำ</h4>';

                if (data.data.herbs && data.data.herbs.length > 0) {
                    data.data.herbs.forEach(herb => {
                        htmlContent += `
                            <div class="mb-4 p-4 border border-green-100 rounded-lg bg-green-50">
                                <h5 class="text-lg font-bold text-green-700 mb-2">${herb.name}</h5>
                                <p class="mb-1"><strong class="text-gray-700">สรรพคุณ:</strong> <span class="text-gray-600">${herb.properties}</span></p>
                                <p><strong class="text-gray-700">วิธีใช้:</strong> <span class="text-gray-600">${herb.usage}</span></p>
                            </div>
                        `;
                    });
                } else {
                    htmlContent += `<p>${JSON.stringify(data.data)}</p>`;
                }

                resultsContainer.innerHTML = htmlContent;
            } else {
                resultsContainer.innerHTML = `<p class="text-red-500 text-center">เกิดข้อผิดพลาด: ${data.message}</p>`;
                alert('เกิดข้อผิดพลาด: ' + data.message);
            }

        } catch (error) {
            console.error('Error:', error);
            resultsContainer.innerHTML = `<p class="text-red-500 text-center">ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้</p>`;
            alert('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้');
        } finally {
            // Reset button
            analyzeBtn.disabled = false;
            analyzeBtn.innerHTML = 'วิเคราะห์';
        }
    });
});
