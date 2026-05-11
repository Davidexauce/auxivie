import { useState, useEffect } from 'react';

export default function Diagnostic() {
  const [results, setResults] = useState({
    loading: true,
    tests: {},
    systemInfo: {},
  });

  useEffect(() => {
    runDiagnostics();
  }, []);

  const runDiagnostics = async () => {
    const tests = {};
    const systemInfo = {};

    // System info
    systemInfo.userAgent = navigator.userAgent;
    systemInfo.online = navigator.onLine;
    systemInfo.language = navigator.language;
    systemInfo.timezone = new Date().getTimezoneString?.() || new Date().toTimeString();

    // Test 1: Browser is online
    try {
      tests.browserOnline = {
        passed: navigator.onLine,
        message: navigator.onLine ? 'Navigateur connecté à internet ✅' : '❌ Navigateur hors ligne',
      };
    } catch (error) {
      tests.browserOnline = {
        passed: false,
        message: 'Impossible de vérifier la connexion',
      };
    }

    // Test 2: Check API reachability (simple GET to health endpoint)
    try {
      console.log('Testing API reachability...');
      const response = await Promise.race([
        fetch('https://api.auxivie.org/api/health', {
          method: 'GET',
          mode: 'cors',
        }),
        new Promise((_, reject) => setTimeout(() => reject(new Error('Timeout')), 5000)),
      ]);
      tests.apiReachability = {
        passed: response.ok,
        message: response.ok ? 'API accessible ✅' : `API responded with ${response.status}`,
      };
    } catch (error) {
      tests.apiReachability = {
        passed: false,
        message: `API unreachable: ${error.message}`,
      };
    }

    // Test 3: Check CORS
    try {
      console.log('Testing CORS...');
      const response = await fetch('https://api.auxivie.org/api/auth/login', {
        method: 'OPTIONS',
        mode: 'cors',
        headers: {
          'Access-Control-Request-Method': 'POST',
          'Access-Control-Request-Headers': 'Content-Type',
        },
      });
      const corsHeader = response.headers.get('access-control-allow-origin');
      tests.cors = {
        passed: corsHeader !== null,
        message: corsHeader ? `CORS enabled ✅ (${corsHeader})` : 'CORS not enabled',
      };
    } catch (error) {
      tests.cors = {
        passed: false,
        message: `CORS check failed: ${error.message}`,
      };
    }

    // Test 4: Check SSL/TLS
    try {
      console.log('Testing SSL...');
      const response = await fetch('https://api.auxivie.org', {
        method: 'HEAD',
      });
      tests.ssl = {
        passed: true,
        message: 'SSL certificate valid ✅',
      };
    } catch (error) {
      tests.ssl = {
        passed: false,
        message: `SSL issue: ${error.message}`,
      };
    }

    // Test 5: Check DNS resolution
    try {
      console.log('Testing DNS...');
      const response = await fetch('https://api.auxivie.org/api/health');
      tests.dns = {
        passed: true,
        message: 'DNS resolution working ✅',
      };
    } catch (error) {
      tests.dns = {
        passed: false,
        message: `DNS issue: ${error.message}`,
      };
    }

    // Test 6: Test actual login endpoint with OPTIONS
    try {
      console.log('Testing login endpoint OPTIONS...');
      const response = await fetch('https://api.auxivie.org/api/auth/login', {
        method: 'OPTIONS',
        mode: 'cors',
        headers: {
          'Access-Control-Request-Method': 'POST',
          'Access-Control-Request-Headers': 'Content-Type,Authorization',
        },
      });
      tests.loginEndpointOPTIONS = {
        passed: response.ok || response.status === 204,
        message: `Login endpoint OPTIONS responding (${response.status}) ✅`,
      };
    } catch (error) {
      tests.loginEndpointOPTIONS = {
        passed: false,
        message: `Login endpoint OPTIONS error: ${error.message}`,
      };
    }

    // Test 7: Test actual login endpoint with POST (invalid credentials expected)
    try {
      console.log('Testing login endpoint POST...');
      const response = await fetch('https://api.auxivie.org/api/auth/login', {
        method: 'POST',
        mode: 'cors',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email: 'test@test.com', password: 'test' }),
      });
      tests.loginEndpointPOST = {
        passed: response.status === 401 || response.status === 200 || response.status === 400,
        message: `Login endpoint responding (${response.status}) ✅`,
      };
    } catch (error) {
      tests.loginEndpointPOST = {
        passed: false,
        message: `Login endpoint POST error: ${error.message}`,
      };
    }

    // Test 8: Test fallback URL via frontend domain
    try {
      console.log('Testing fallback URL (auxivie.org/api)...');
      const response = await fetch('https://auxivie.org/api/auth/login', {
        method: 'POST',
        mode: 'cors',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email: 'test@test.com', password: 'test' }),
      });
      tests.fallbackFrontendDomain = {
        passed: response.status === 401 || response.status === 200 || response.status === 400,
        message: `Fallback via frontend domain working ✅`,
      };
    } catch (error) {
      tests.fallbackFrontendDomain = {
        passed: false,
        message: `Fallback frontend domain failed: ${error.message}`,
      };
    }

    // Test 9: Test fallback URL via direct IP
    try {
      console.log('Testing fallback URL (Direct IP:8080)...');
      const response = await fetch('http://178.16.131.24:8080/api/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email: 'test@test.com', password: 'test' }),
      });
      tests.fallbackDirectIP = {
        passed: response.status === 401 || response.status === 200 || response.status === 400,
        message: `Fallback via direct IP working ✅`,
      };
    } catch (error) {
      tests.fallbackDirectIP = {
        passed: false,
        message: `Fallback direct IP failed: ${error.message}`,
      };
    }

    // Test 8: Browser info
    tests.browser = {
      passed: true,
      message: `${navigator.userAgent.substring(0, 70)}...`,
    };

    setResults({
      loading: false,
      tests,
      systemInfo,
    });
  };

  const allTestsPassed = Object.values(results.tests).every(t => t.passed);

  return (
    <div style={{ padding: '40px', fontFamily: 'Arial, sans-serif', maxWidth: '900px', margin: '0 auto' }}>
      <h1>🔍 Diagnostic - Aidalya Admin</h1>
      <p>Cette page teste la connectivité entre votre navigateur et le serveur API.</p>

      <div style={{ marginTop: '20px', padding: '15px', backgroundColor: '#f0fdf4', borderRadius: '8px', border: '1px solid #86efac' }}>
        <strong>État du diagnostic:</strong>
        <p style={{ margin: '5px 0' }}>
          Connexion Internet: {results.systemInfo.online ? '✅ En ligne' : '❌ Hors ligne'}
        </p>
        <p style={{ margin: '5px 0' }}>
          Navigateur: {results.systemInfo.userAgent?.substring(0, 50)}...
        </p>
      </div>

      <div style={{ marginTop: '30px' }}>
        <h2>Résultats des tests</h2>
        {results.loading ? (
          <p>Exécution des tests en cours...</p>
        ) : (
          <div>
            {Object.entries(results.tests).map(([testName, result]) => (
              <div
                key={testName}
                style={{
                  padding: '15px',
                  marginBottom: '15px',
                  border: `2px solid ${result.passed ? '#16a34a' : '#dc2626'}`,
                  borderRadius: '8px',
                  backgroundColor: result.passed ? '#f0fdf4' : '#fef2f2',
                }}
              >
                <strong style={{ color: result.passed ? '#166534' : '#991b1b' }}>
                  {testName.replace(/([A-Z])/g, ' $1').trim()}:
                </strong>
                <p style={{ margin: '8px 0 0 0', color: result.passed ? '#166534' : '#991b1b' }}>
                  {result.message}
                </p>
              </div>
            ))}
          </div>
        )}
      </div>

      <div style={{ marginTop: '40px', padding: '20px', backgroundColor: allTestsPassed ? '#f0fdf4' : '#fef2f2', borderRadius: '8px', border: `2px solid ${allTestsPassed ? '#16a34a' : '#dc2626'}` }}>
        <h3>{allTestsPassed ? '✅ Tous les tests réussis!' : '⚠️ Certains tests ont échoué'}</h3>
        
        {allTestsPassed ? (
          <p>
            Votre connexion au serveur API semble fonctionner correctement. Si vous rencontrez toujours des problèmes de login, il peut s'agir d'un problème d'authentification (email/mot de passe incorrect) plutôt qu'un problème de connexion.
          </p>
        ) : (
          <div>
            <p><strong>Important:</strong> Si les premiers tests échouent mais les fallbacks (auxivie.org/api ou IP directe) réussissent, c'est que votre réseau bloque les connexions vers le domaine api.auxivie.org. Ne vous inquiétez pas - l'application bascule automatiquement vers les fallbacks!</p>
            
            <p><strong>Résumé des résultats:</strong></p>
            <ul>
              <li>🔴 Tests vers api.auxivie.org échouent? → Votre réseau bloque ce domaine</li>
              <li>🟢 Fallback via auxivie.org/api réussit? → L'application fonctionnera normalement</li>
              <li>🟢 Fallback via IP directe réussit? → L'application fonctionnera aussi avec cette URL</li>
            </ul>
            
            <p><strong>Les causes courantes:</strong></p>
            <ul>
              <li><strong>Pare-feu/proxy d'entreprise:</strong> Bloque les domaines externes (api.auxivie.org)</li>
              <li><strong>Filtrage DNS:</strong> Le fournisseur Internet bloque la résolution de ce domaine</li>
              <li><strong>Filtrage de contenu:</strong> Votre réseau a des règles strictes sur les domaines</li>
              <li><strong>Antivirus/VPN personnel:</strong> Peut bloquer certaines connexions</li>
            </ul>
            
            <p><strong>Solutions recommandées:</strong></p>
            <ul>
              <li>✅ Si un fallback fonctionne, vous pouvez vous connecter normalement</li>
              <li>Essayez sur un autre réseau (Hotspot mobile, réseau public, VPN)</li>
              <li>Essayez sur un autre navigateur ou appareil</li>
              <li>Contactez votre administrateur réseau si vous êtes sur un réseau d'entreprise</li>
            </ul>
          </div>
        )}
      </div>

      <div style={{ marginTop: '30px', padding: '20px', backgroundColor: '#f9f9f9', borderRadius: '8px', border: '1px solid #e5e7eb' }}>
        <h3>Informations système (à partager si vous demandez de l'aide)</h3>
        <pre style={{ backgroundColor: '#f3f4f6', padding: '10px', borderRadius: '4px', fontSize: '12px', overflow: 'auto' }}>
{JSON.stringify({
  navigator: {
    userAgent: results.systemInfo.userAgent,
    language: results.systemInfo.language,
    onLine: results.systemInfo.online,
  },
  testResults: Object.entries(results.tests).reduce((acc, [key, val]) => {
    acc[key] = val.passed ? 'PASS' : 'FAIL';
    return acc;
  }, {}),
}, null, 2)}
        </pre>
      </div>

      <div style={{ marginTop: '20px', textAlign: 'center' }}>
        <button
          onClick={runDiagnostics}
          style={{
            padding: '10px 20px',
            backgroundColor: '#16a34a',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer',
            fontSize: '14px',
            fontWeight: 'bold',
          }}
        >
          Re-tester
        </button>
        <button
          onClick={() => window.location.href = '/login'}
          style={{
            padding: '10px 20px',
            marginLeft: '10px',
            backgroundColor: '#0066cc',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer',
            fontSize: '14px',
            fontWeight: 'bold',
          }}
        >
          Retour à la connexion
        </button>
      </div>
    </div>
  );
}
