const jwt = require('jsonwebtoken');
const axios = require('axios');

// Configuration
const BUNDLE_ID = "hm.orz.chaos114.TumeKyouen";

const VERSION_NAME = process.env.VERSION_NAME;
const API_KEY_ID = process.env.APPLE_KEY_ID;
const ISSUER_ID = process.env.APPLE_ISSUER_ID;
const PRIVATE_KEY = process.env.P8_APPSTORECONNECT_API;

// Default release notes
const DEFAULT_RELEASE_NOTES = 'バグを修正しました';

// Generate JWT token for App Store Connect API
function generateJWT() {
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: ISSUER_ID,
    aud: 'appstoreconnect-v1',
    iat: now,
    exp: now + 1200, // 20 minutes
  };

  const header = {
    alg: 'ES256',
    kid: API_KEY_ID,
    typ: 'JWT'
  };

  return jwt.sign(payload, PRIVATE_KEY, {
    algorithm: 'ES256',
    header: header
  });
}

// Create axios instance with auth header
function createAPIClient() {
  const token = generateJWT();
  return axios.create({
    baseURL: 'https://api.appstoreconnect.apple.com/v1',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
}

async function main() {
  try {
    // Validate required environment variables
    const requiredEnvVars = {
      'VERSION_NAME': VERSION_NAME,
      'APPLE_KEY_ID': API_KEY_ID,
      'APPLE_ISSUER_ID': ISSUER_ID,
      'P8_APPSTORECONNECT_API': PRIVATE_KEY
    };

    const missingVars = [];
    for (const [name, value] of Object.entries(requiredEnvVars)) {
      if (!value) {
        missingVars.push(name);
      }
    }

    if (missingVars.length > 0) {
      throw new Error(`Missing required environment variables: ${missingVars.join(', ')}`);
    }

    console.log('Environment variables validation passed');

    const api = createAPIClient();

    console.log(`Starting preparation for version ${VERSION_NAME}`);

    // 1. Get app information by bundle ID
    console.log('1. Fetching app information...');
    const appsResponse = await api.get(`/apps?filter[bundleId]=${BUNDLE_ID}`);

    if (appsResponse.data.data.length === 0) {
      throw new Error(`App with bundle ID ${BUNDLE_ID} not found`);
    }

    const app = appsResponse.data.data[0];
    const appId = app.id;
    console.log(`Found app: ${app.attributes.name} (ID: ${appId})`);

    // 2. Get app store versions
    console.log('2. Fetching app store versions...');
    const versionsResponse = await api.get(`/apps/${appId}/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION,DEVELOPER_REJECTED,REJECTED,METADATA_REJECTED,WAITING_FOR_REVIEW,IN_REVIEW,PENDING_DEVELOPER_RELEASE`);

    let versionId;
    let isNewVersion = false;

    if (versionsResponse.data.data.length > 0) {
      // Update existing version
      console.log('Found existing version, updating...');
      const existingVersion = versionsResponse.data.data[0];
      versionId = existingVersion.id;

      await api.patch(`/appStoreVersions/${versionId}`, {
        data: {
          type: 'appStoreVersions',
          id: versionId,
          attributes: {
            versionString: VERSION_NAME
          }
        }
      });
      console.log(`Updated version string to ${VERSION_NAME}`);
    } else {
      // Create new version
      console.log('No editable version found, creating new version...');
      isNewVersion = true;

      const createVersionResponse = await api.post('/appStoreVersions', {
        data: {
          type: 'appStoreVersions',
          attributes: {
            versionString: VERSION_NAME,
            platform: 'IOS'
          },
          relationships: {
            app: {
              data: {
                type: 'apps',
                id: appId
              }
            }
          }
        }
      });

      versionId = createVersionResponse.data.data.id;
      console.log(`Created new version ${VERSION_NAME} (ID: ${versionId})`);
    }

    // 3. Get and update localization (release notes)
    console.log('3. Updating release notes...');
    const localizationsResponse = await api.get(`/appStoreVersions/${versionId}/appStoreVersionLocalizations`);

    if (localizationsResponse.data.data.length > 0) {
      // Update existing localizations
      for (const localization of localizationsResponse.data.data) {
        await api.patch(`/appStoreVersionLocalizations/${localization.id}`, {
          data: {
            type: 'appStoreVersionLocalizations',
            id: localization.id,
            attributes: {
              whatsNew: DEFAULT_RELEASE_NOTES
            }
          }
        });
        console.log(`Updated release notes for locale: ${localization.attributes.locale}`);
      }
    } else if (isNewVersion) {
      // Create Japanese localization for new version
      await api.post('/appStoreVersionLocalizations', {
        data: {
          type: 'appStoreVersionLocalizations',
          attributes: {
            locale: 'ja-JP',
            whatsNew: DEFAULT_RELEASE_NOTES
          },
          relationships: {
            appStoreVersion: {
              data: {
                type: 'appStoreVersions',
                id: versionId
              }
            }
          }
        }
      });
      console.log('Created Japanese localization with default release notes');
    }

    // 4. Get latest build
    console.log('4. Fetching latest build...');
    const buildsResponse = await api.get(`/apps/${appId}/builds?limit=200`);

    if (buildsResponse.data.data.length === 0) {
      console.log('Warning: No builds found for this app. Please upload a build first.');
      return;
    }

    // Sort builds manually to get the latest one
    // Note: attributes.version is expected to be an integer value in this workflow
    const latestBuild = buildsResponse.data.data.reduce((latest, current) => {
      const latestVersion = parseInt(latest.attributes.version) || 0;
      const currentVersion = parseInt(current.attributes.version) || 0;
      return currentVersion > latestVersion ? current : latest;
    });
    const buildId = latestBuild.id;
    console.log(`Found latest build: ${latestBuild.attributes.version} (ID: ${buildId})`);

    // 5. Assign build to version
    console.log('5. Assigning build to version...');
    await api.patch(`/appStoreVersions/${versionId}/relationships/build`, {
      data: {
        type: 'builds',
        id: buildId
      }
    });
    console.log(`Successfully assigned build ${buildId} to version ${versionId}`);

    console.log(`✅ Release preparation completed for version ${VERSION_NAME}`);
    console.log('The app is now ready for review submission in App Store Connect.');

  } catch (error) {
    console.error('❌ Error during release preparation:', error.message);

    // Log detailed error information for API errors
    if (error.response) {
      console.error('API Error Details:');
      console.error(`Status: ${error.response.status}`);
      console.error(`URL: ${error.config?.url || 'Unknown'}`);
      console.error(`Method: ${error.config?.method?.toUpperCase() || 'Unknown'}`);
      console.error('Response:', JSON.stringify(error.response.data, null, 2));
    } else if (error.request) {
      console.error('Network Error: No response received from the server');
    } else {
      console.error('Error Details:', error.stack || error.toString());
    }

    process.exit(1);
  }
}

main();
