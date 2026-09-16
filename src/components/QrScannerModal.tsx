import React, { useEffect, useRef, useState } from 'react';
import { X, Camera, Upload, AlertCircle, Sparkles, CheckCircle2 } from 'lucide-react';
import jsQR from 'jsqr';
import { parseUpiUri, ParsedUpiData } from '../services/upiService';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  onScanSuccess: (data: ParsedUpiData) => void;
}

export const QrScannerModal: React.FC<Props> = ({ isOpen, onClose, onScanSuccess }) => {
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  const [hasCamera, setHasCamera] = useState<boolean>(true);
  const [cameraError, setCameraError] = useState<string | null>(null);
  const [scannedResult, setScannedResult] = useState<ParsedUpiData | null>(null);
  const streamRef = useRef<MediaStream | null>(null);
  const animationFrameId = useRef<number | null>(null);

  // Stop camera stream safely
  const stopCamera = () => {
    if (animationFrameId.current) {
      cancelAnimationFrame(animationFrameId.current);
      animationFrameId.current = null;
    }
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop());
      streamRef.current = null;
    }
  };

  // Start live camera stream
  useEffect(() => {
    if (!isOpen) {
      stopCamera();
      setScannedResult(null);
      setCameraError(null);
      return;
    }

    let isSubscribed = true;

    const startCamera = async () => {
      try {
        setCameraError(null);
        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
          throw new Error('Camera not supported in this browser');
        }

        const stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: { ideal: 'environment' } },
        });

        if (!isSubscribed) {
          stream.getTracks().forEach((t) => t.stop());
          return;
        }

        streamRef.current = stream;
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          videoRef.current.setAttribute('playsinline', 'true');
          await videoRef.current.play();
          requestAnimationFrame(scanVideoFrame);
        }
      } catch (err: any) {
        console.warn('Camera access error:', err);
        setHasCamera(false);
        setCameraError('Camera unavailable or permission denied. You can upload a QR image or select a sample QR below.');
      }
    };

    startCamera();

    return () => {
      isSubscribed = false;
      stopCamera();
    };
  }, [isOpen]);

  // Continuously scan video frames
  const scanVideoFrame = () => {
    if (!videoRef.current || !canvasRef.current) return;

    const video = videoRef.current;
    if (video.readyState === video.HAVE_ENOUGH_DATA) {
      const canvas = canvasRef.current;
      const ctx = canvas.getContext('2d', { willReadFrequently: true });

      if (ctx) {
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

        const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
        const code = jsQR(imageData.data, imageData.width, imageData.height, {
          inversionAttempts: 'dontInvert',
        });

        if (code && code.data) {
          handleDecodedData(code.data);
          return; // Stop scanning once found
        }
      }
    }

    animationFrameId.current = requestAnimationFrame(scanVideoFrame);
  };

  // Process decoded string
  const handleDecodedData = (rawText: string) => {
    const parsed = parseUpiUri(rawText);
    if (parsed) {
      stopCamera();
      setScannedResult(parsed);
      setTimeout(() => {
        onScanSuccess(parsed);
        onClose();
      }, 700);
    } else {
      setCameraError(`Decoded QR code is not a valid UPI format: "${rawText.slice(0, 30)}..."`);
    }
  };

  // Handle uploaded QR image file
  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        const ctx = canvas.getContext('2d');
        if (ctx) {
          ctx.drawImage(img, 0, 0);
          const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
          const code = jsQR(imageData.data, imageData.width, imageData.height);
          if (code && code.data) {
            handleDecodedData(code.data);
          } else {
            setCameraError('No QR code detected in the uploaded image. Please try another image.');
          }
        }
      };
      img.src = event.target?.result as string;
    };
    reader.readAsDataURL(file);
  };

  // Preset sample QR codes for immediate testing
  const samplePresets = [
    {
      title: 'Suresh Electronics',
      vpa: 'merchantstore@oksbi',
      amount: 3500,
      note: 'Hardware parts',
      uri: 'upi://pay?pa=merchantstore@oksbi&pn=Suresh%20Electronics&am=3500.00&cu=INR&tn=Hardware%20parts',
    },
    {
      title: 'Fresh Mart Supermarket',
      vpa: 'freshmart.pay@icici',
      amount: 4850,
      note: 'Monthly groceries',
      uri: 'upi://pay?pa=freshmart.pay@icici&pn=Fresh%20Mart&am=4850.00&cu=INR&tn=Monthly%20groceries',
    },
    {
      title: 'Metro Electronics Store',
      vpa: 'metroelec@hdfcbank',
      amount: 7200,
      note: 'Appliance purchase',
      uri: 'upi://pay?pa=metroelec@hdfcbank&pn=Metro%20Electronics&am=7200.00&cu=INR&tn=Appliance%20purchase',
    },
  ];

  if (!isOpen) return null;

  return (
    <div
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        background: 'rgba(0, 0, 0, 0.75)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '16px',
        zIndex: 99999,
        backdropFilter: 'blur(6px)',
      }}
      onClick={onClose}
    >
      <div
        className="gpay-card"
        style={{
          width: '100%',
          maxWidth: '420px',
          background: '#FFFFFF',
          padding: '20px',
          maxHeight: '92vh',
          overflowY: 'auto',
          position: 'relative',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Camera size={20} color="#1A73E8" />
            <h2 style={{ fontSize: '1.1rem', fontWeight: 700, color: '#1F2937' }}>
              Scan Any UPI QR Code
            </h2>
          </div>
          <button
            type="button"
            onClick={onClose}
            style={{
              background: '#F1F3F4',
              border: 'none',
              borderRadius: '50%',
              width: '32px',
              height: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              color: '#5F6368',
            }}
          >
            <X size={18} />
          </button>
        </div>

        {/* Camera Viewport / Scanning Area */}
        <div
          style={{
            position: 'relative',
            width: '100%',
            height: '240px',
            background: '#0B0F19',
            borderRadius: 'var(--radius-lg)',
            overflow: 'hidden',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: '14px',
          }}
        >
          {hasCamera && !cameraError ? (
            <>
              <video
                ref={videoRef}
                style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                muted
              />
              <canvas ref={canvasRef} style={{ display: 'none' }} />

              {/* Google Pay Style Target Reticle */}
              <div
                style={{
                  position: 'absolute',
                  width: '170px',
                  height: '170px',
                  border: '2px solid rgba(255, 255, 255, 0.4)',
                  borderRadius: '16px',
                  boxShadow: '0 0 0 9999px rgba(0, 0, 0, 0.45)',
                  pointerEvents: 'none',
                }}
              >
                {/* Corner markers */}
                <div style={{ position: 'absolute', top: -2, left: -2, width: 22, height: 22, borderTop: '4px solid #1A73E8', borderLeft: '4px solid #1A73E8', borderRadius: '6px 0 0 0' }} />
                <div style={{ position: 'absolute', top: -2, right: -2, width: 22, height: 22, borderTop: '4px solid #1A73E8', borderRight: '4px solid #1A73E8', borderRadius: '0 6px 0 0' }} />
                <div style={{ position: 'absolute', bottom: -2, left: -2, width: 22, height: 22, borderBottom: '4px solid #1A73E8', borderLeft: '4px solid #1A73E8', borderRadius: '0 0 0 6px' }} />
                <div style={{ position: 'absolute', bottom: -2, right: -2, width: 22, height: 22, borderBottom: '4px solid #1A73E8', borderRight: '4px solid #1A73E8', borderRadius: '0 0 6px 0' }} />

                {/* Scanning laser line */}
                <div
                  style={{
                    position: 'absolute',
                    top: 0,
                    left: 0,
                    right: 0,
                    height: '2px',
                    background: 'linear-gradient(90deg, transparent, #1A73E8, transparent)',
                    boxShadow: '0 0 8px #1A73E8',
                    animation: 'scan-laser 2s infinite ease-in-out',
                  }}
                />
              </div>
            </>
          ) : (
            <div style={{ padding: '20px', textAlign: 'center', color: '#94A3B8', fontSize: '0.85rem' }}>
              <AlertCircle size={32} color="#F9AB00" style={{ margin: '0 auto 8px auto' }} />
              <p>{cameraError || 'Camera unavailable'}</p>
            </div>
          )}

          {/* Success Overlay on scan */}
          {scannedResult && (
            <div
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                background: 'rgba(15, 157, 88, 0.9)',
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#FFFFFF',
                gap: '8px',
              }}
            >
              <CheckCircle2 size={42} />
              <span style={{ fontWeight: 700, fontSize: '1rem' }}>QR Code Verified!</span>
              <span style={{ fontSize: '0.8rem' }}>{scannedResult.vpa}</span>
            </div>
          )}
        </div>

        {/* Upload QR Image Button */}
        <div style={{ display: 'flex', gap: '8px', marginBottom: '14px' }}>
          <button
            type="button"
            onClick={() => fileInputRef.current?.click()}
            className="btn-secondary-gpay"
            style={{ width: '100%', padding: '10px' }}
          >
            <Upload size={16} />
            <span>Upload QR Image / Screenshot</span>
          </button>
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            style={{ display: 'none' }}
            onChange={handleFileUpload}
          />
        </div>

        {/* Quick Sample QR Codes (Perfect for Emulators & Testing) */}
        <div style={{ borderTop: '1px solid #ECEFF1', paddingTop: '12px' }}>
          <div style={{ fontSize: '0.75rem', fontWeight: 700, color: '#5F6368', textTransform: 'uppercase', marginBottom: '8px', display: 'flex', alignItems: 'center', gap: '4px' }}>
            <Sparkles size={13} color="#1A73E8" />
            <span>Or Pick Sample Merchant QR</span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
            {samplePresets.map((preset) => (
              <button
                key={preset.vpa}
                type="button"
                onClick={() => handleDecodedData(preset.uri)}
                style={{
                  background: '#F8F9FA',
                  border: '1px solid #E5E7EB',
                  borderRadius: 'var(--radius-md)',
                  padding: '8px 12px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  cursor: 'pointer',
                  textAlign: 'left',
                  transition: 'background 0.15s ease',
                }}
              >
                <div>
                  <div style={{ fontWeight: 600, fontSize: '0.85rem', color: '#1F2937' }}>
                    {preset.title}
                  </div>
                  <div style={{ fontSize: '0.72rem', color: '#5F6368' }}>
                    {preset.vpa} &bull; {preset.note}
                  </div>
                </div>
                <div style={{ fontWeight: 700, fontSize: '0.88rem', color: '#1A73E8' }}>
                  ₹{preset.amount.toLocaleString('en-IN')}
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>

      <style>{`
        @keyframes scan-laser {
          0% { top: 0%; opacity: 0.8; }
          50% { top: 96%; opacity: 1; }
          100% { top: 0%; opacity: 0.8; }
        }
      `}</style>
    </div>
  );
};
