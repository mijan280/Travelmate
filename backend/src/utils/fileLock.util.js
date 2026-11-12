/**
 * In-memory Mutex / Lock Utility to prevent concurrent file writes from corrupting JSON files.
 */
class FileMutex {
  constructor() {
    this.locks = new Map();
  }

  async acquire(key) {
    while (this.locks.get(key)) {
      await this.locks.get(key);
    }

    let release;
    const promise = new Promise((resolve) => {
      release = resolve;
    });

    this.locks.set(key, promise);

    return () => {
      this.locks.delete(key);
      release();
    };
  }
}

const fileMutex = new FileMutex();

module.exports = fileMutex;
