import { useEffect, useMemo, useState } from "react";

const API = "http://localhost:8000";

function Profile() {
  const [email, setEmail] = useState("");
  const [profile, setProfile] = useState(null);
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);
  const token = localStorage.getItem("token");

  useEffect(() => {
    if (!token) { setLoading(false); return; }

    Promise.all([
      fetch(`${API}/auth/me`,      { headers: { Authorization: `Bearer ${token}` } }).then(r => r.json()),
      fetch(`${API}/profile/me`,   { headers: { Authorization: `Bearer ${token}` } }).then(r => r.ok ? r.json() : null),
      fetch(`${API}/documents/me`, { headers: { Authorization: `Bearer ${token}` } }).then(r => r.ok ? r.json() : []),
    ]).then(([me, prof, docs]) => {
      setEmail(me.email || "");
      setProfile(prof);
      setDocuments(docs);
      setLoading(false);
    });
  }, []);

  const hasResume = documents.some(
    (d) => d.document_type.toLowerCase() === "resume"
  );

  const completionFields = [
    { label: "First Name",    done: !!profile?.first_name },
    { label: "Last Name",     done: !!profile?.last_name },
    { label: "Email",         done: !!email },
    { label: "Phone Number",  done: !!profile?.phone_number },
    { label: "Date of Birth", done: !!profile?.dob },
    { label: "Summary",       done: !!profile?.summary },
    { label: "Resume",        done: hasResume },
  ];

  const completedCount = completionFields.filter((f) => f.done).length;
  const completionPct  = Math.round((completedCount / completionFields.length) * 100);
  const missingFields  = completionFields.filter((f) => !f.done);

  if (loading) return <div style={styles.page}><p style={{ color: "#888" }}>Loading…</p></div>;

  return (
    <div style={styles.page}>
      <h1 style={styles.title}>Profile</h1>
      <p style={styles.subtitle}>Your account information at a glance.</p>

      {/* Completion */}
      <div style={styles.card}>
        <h2 style={styles.cardTitle}>Profile Completion</h2>
        <p style={styles.percentageText}>{completionPct}% complete</p>
        <div style={styles.progressBar}>
          <div style={{ ...styles.progressFill, width: `${completionPct}%` }} />
        </div>
        <p style={styles.helperText}>{completedCount} of {completionFields.length} items complete</p>
      </div>

      {/* Summary */}
      <div style={styles.card}>
        <h2 style={styles.cardTitle}>Profile Summary</h2>
        <div style={styles.summaryGrid}>
          <InfoRow label="First Name"    value={profile?.first_name} />
          <InfoRow label="Last Name"     value={profile?.last_name} />
          <InfoRow label="Email"         value={email} />
          <InfoRow label="Phone"         value={profile?.phone_number} />
          <InfoRow label="Date of Birth" value={profile?.dob} />
          <InfoRow label="Resume"        value={hasResume ? "Uploaded" : "Not uploaded"} />
        </div>
      </div>

      {/* Summary / Bio */}
      {profile?.summary && (
        <div style={styles.card}>
          <h2 style={styles.cardTitle}>About</h2>
          <p style={styles.summaryText}>{profile.summary}</p>
        </div>
      )}

      {/* Missing fields — only shown when incomplete */}
      {missingFields.length > 0 && (
        <div style={styles.card}>
          <h2 style={styles.cardTitle}>Missing Information</h2>
          <ul style={styles.missingList}>
            {missingFields.map((f) => (
              <li key={f.label} style={styles.missingItem}>
                {f.label} — <span style={{ color: "#888" }}>
                  {f.label === "Resume" ? "upload via Document Library" : "update in Settings"}
                </span>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

function InfoRow({ label, value }) {
  return (
    <div>
      <p style={styles.summaryLabel}>{label}</p>
      <p style={styles.summaryValue}>{value || <span style={{ color: "#aaa" }}>Not set</span>}</p>
    </div>
  );
}

const styles = {
  page:           { maxWidth: "900px", margin: "0 auto", padding: "32px 20px", fontFamily: "Arial, sans-serif" },
  title:          { fontSize: "32px", marginBottom: "8px" },
  subtitle:       { color: "#555", marginBottom: "24px" },
  card:           { backgroundColor: "#fff", border: "1px solid #ddd", borderRadius: "12px", padding: "24px", marginBottom: "20px" },
  cardTitle:      { fontSize: "22px", marginBottom: "12px" },
  percentageText: { fontSize: "24px", fontWeight: "700" },
  progressBar:    { width: "100%", height: "14px", backgroundColor: "#e5e7eb", borderRadius: "999px", overflow: "hidden", margin: "10px 0" },
  progressFill:   { height: "100%", backgroundColor: "#22c55e", transition: "width 0.3s ease" },
  helperText:     { fontSize: "14px", color: "#555" },
  summaryGrid:    { display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: "16px" },
  summaryLabel:   { fontSize: "13px", color: "#666", margin: 0 },
  summaryValue:   { fontSize: "15px", fontWeight: "600", wordBreak: "break-word", margin: "4px 0 0" },
  summaryText:    { fontSize: "15px", color: "#333", lineHeight: "1.6" },
  missingList:    { paddingLeft: "20px" },
  missingItem:    { marginBottom: "8px" },
  successText:    { color: "green", fontWeight: "600" },
};

export default Profile;
