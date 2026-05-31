import { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { fetchAdminAlerts } from '../lib/adminAlerts';

const AdminAlertsContext = createContext({
  alerts: [],
  navBadges: {},
  totalCount: 0,
  loading: true,
  refresh: () => {},
});

export function AdminAlertsProvider({ children }) {
  const [alerts, setAlerts] = useState([]);
  const [navBadges, setNavBadges] = useState({});
  const [totalCount, setTotalCount] = useState(0);
  const [loading, setLoading] = useState(true);

  const refresh = useCallback(async () => {
    try {
      const data = await fetchAdminAlerts();
      setAlerts(data.alerts);
      setNavBadges(data.navBadges);
      setTotalCount(data.totalCount);
    } catch (e) {
      console.error('Alertes admin:', e);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const token = localStorage.getItem('token');
    if (!token) {
      setLoading(false);
      return;
    }
    refresh();
    const interval = setInterval(refresh, 30000);
    return () => clearInterval(interval);
  }, [refresh]);

  return (
    <AdminAlertsContext.Provider
      value={{ alerts, navBadges, totalCount, loading, refresh }}
    >
      {children}
    </AdminAlertsContext.Provider>
  );
}

export function useAdminAlerts() {
  return useContext(AdminAlertsContext);
}
