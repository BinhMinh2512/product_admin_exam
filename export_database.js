
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const fs = require('fs');
const path = require('path');

const serviceAccount = require(
  'D:/firebase_keys/serviceAccountKey.json'
);

initializeApp({
  credential: cert(serviceAccount),
});

async function exportProducts() {
  try {
    const db = getFirestore();
    const snapshot = await db.collection('products').get();

    const products = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    const outputDir = path.join(__dirname, 'database');
    fs.mkdirSync(outputDir, { recursive: true });

    fs.writeFileSync(
      path.join(outputDir, 'products.json'),
      JSON.stringify(products, null, 2),
      'utf8'
    );

    console.log(`Da xuat ${products.length} san pham thanh cong!`);
    console.log('File: database/products.json');
  } catch (error) {
    console.error('Loi xuat database:', error);
  } finally {
    await require('firebase-admin/app').deleteApp(
      require('firebase-admin/app').getApp()
    );
  }
}

exportProducts();
