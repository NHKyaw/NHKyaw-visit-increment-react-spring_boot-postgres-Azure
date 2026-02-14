import React, { useState, useEffect } from 'react';

function App() {
  const [count, setCount] = useState(0);
  const [loading, setLoading] = useState(true);
  
  // 1. Run 'ip addr' in your VMware terminal
  // 2. Replace the IP below with your actual VM IP address
  const VM_IP = "3.1.108.202"; 
  const BASE_URL = `http://${VM_IP}:8080/api/visit`;

  const refreshCount = async () => {
    setLoading(true);
    try {
      // Step 4: Use the full absolute path /api/visit/count
      const res = await fetch(`${BASE_URL}/count`);
      if (!res.ok) throw new Error("Check if Backend is running in VM");
      
      const data = await res.json();
      
      // CRITICAL: Access .count because Java returns a Map
      // Fallback logic handles both object and raw number returns
      if (data && typeof data.count !== 'undefined') {
        setCount(data.count);
      } else {
        setCount(data);
      }
      
      setLoading(false);
    } catch (err) {
      console.error("Connection Error:", err);
      setLoading(false);
    }
  };

  const handleVisit = async () => {
    try {
      const response = await fetch(BASE_URL, { method: 'POST' });
      if (!response.ok) throw new Error("POST failed");
      
      // Small delay ensures DB write is complete before refreshing
      setTimeout(() => refreshCount(), 200); 
    } catch (err) {
      console.error("CORS/Network Error:", err);
    }
  };

  useEffect(() => { 
    refreshCount(); 
  }, []);

  return (
    <div style={{ textAlign: 'center', padding: '50px', fontFamily: 'Arial' }}>
      <div style={{ padding: '30px', border: '1px solid #ddd', display: 'inline-block', borderRadius: '10px' }}>
        <h1>CI/CD Test App:UAT:v1</h1>
        <hr />
        <h2>Total Visits in Our Database:</h2>
        
        {loading ? (
          <p>Loading...</p>
        ) : (
          <h1 style={{ fontSize: '4rem', color: '#007bff' }}>{count}</h1>
        )}

        <button 
          onClick={handleVisit} 
          style={{ 
            padding: '10px 20px', 
            backgroundColor: '#28a745', 
            color: 'white', 
            border: 'none', 
            borderRadius: '5px', 
            cursor: 'pointer' 
          }}
        >
          Log New Visit
        </button>
      </div>
    </div>
  );
}

export default App;