const fs = require('fs');
const path = require('path');
const IStorageAdapter = require('../interfaces/IStorageAdapter');
const fileMutex = require('../../utils/fileLock.util');

class JsonStorageAdapter extends IStorageAdapter {
  constructor(dataDirectory) {
    super();
    this.dataDir = dataDirectory;
    this._ensureDirectoryExists();
  }

  _ensureDirectoryExists() {
    if (!fs.existsSync(this.dataDir)) {
      fs.mkdirSync(this.dataDir, { recursive: true });
    }
  }

  _getFilePath(collectionName) {
    return path.join(this.dataDir, `${collectionName}.json`);
  }

  async read(collectionName) {
    const filePath = this._getFilePath(collectionName);
    const release = await fileMutex.acquire(filePath);

    try {
      if (!fs.existsSync(filePath)) {
        // Initialize with empty array if file does not exist
        await fs.promises.writeFile(filePath, JSON.stringify([], null, 2), 'utf-8');
        return [];
      }

      const raw = await fs.promises.readFile(filePath, 'utf-8');
      if (!raw || raw.trim() === '') {
        return [];
      }

      try {
        const parsed = JSON.parse(raw);
        return Array.isArray(parsed) ? parsed : [];
      } catch (parseError) {
        console.error(`[JsonStorageAdapter] Corrupted JSON in ${filePath}. Creating backup...`, parseError);
        const backupPath = `${filePath}.corrupt.${Date.now()}`;
        await fs.promises.copyFile(filePath, backupPath);
        await fs.promises.writeFile(filePath, JSON.stringify([], null, 2), 'utf-8');
        return [];
      }
    } finally {
      release();
    }
  }

  async write(collectionName, items) {
    if (!Array.isArray(items)) {
      throw new Error('Items to write must be an array.');
    }

    const filePath = this._getFilePath(collectionName);
    const tempPath = `${filePath}.tmp.${Date.now()}`;
    const release = await fileMutex.acquire(filePath);

    try {
      this._ensureDirectoryExists();
      const content = JSON.stringify(items, null, 2);
      // Atomic write: write to temp file then rename
      await fs.promises.writeFile(tempPath, content, 'utf-8');
      await fs.promises.rename(tempPath, filePath);
    } catch (err) {
      if (fs.existsSync(tempPath)) {
        try {
          await fs.promises.unlink(tempPath);
        } catch (_) {}
      }
      throw err;
    } finally {
      release();
    }
  }

  async find(collectionName, predicate = () => true) {
    const items = await this.read(collectionName);
    return items.filter(predicate);
  }

  async findOne(collectionName, predicate) {
    const items = await this.read(collectionName);
    return items.find(predicate) || null;
  }

  async findById(collectionName, id) {
    return this.findOne(collectionName, (item) => String(item.id) === String(id));
  }

  async insert(collectionName, item) {
    const items = await this.read(collectionName);
    const newItem = {
      ...item,
      id: item.id || Date.now().toString(),
      createdAt: item.createdAt || new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    items.push(newItem);
    await this.write(collectionName, items);
    return newItem;
  }

  async update(collectionName, id, updates) {
    const items = await this.read(collectionName);
    const index = items.findIndex((item) => String(item.id) === String(id));
    if (index === -1) {
      return null;
    }

    const updatedItem = {
      ...items[index],
      ...updates,
      id: items[index].id, // protect ID from mutation
      updatedAt: new Date().toISOString(),
    };

    items[index] = updatedItem;
    await this.write(collectionName, items);
    return updatedItem;
  }

  async delete(collectionName, id) {
    const items = await this.read(collectionName);
    const index = items.findIndex((item) => String(item.id) === String(id));
    if (index === -1) {
      return false;
    }

    items.splice(index, 1);
    await this.write(collectionName, items);
    return true;
  }
}

module.exports = JsonStorageAdapter;
