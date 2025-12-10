import styles from '../styles/Pagination.module.css';

export default function Pagination({ 
  currentPage, 
  totalPages, 
  onPageChange, 
  itemsPerPage = 10,
  totalItems,
  onItemsPerPageChange 
}) {
  if (totalPages <= 1) return null;

  const pages = [];
  const maxVisiblePages = 5;
  
  let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
  let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
  
  if (endPage - startPage < maxVisiblePages - 1) {
    startPage = Math.max(1, endPage - maxVisiblePages + 1);
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i);
  }

  const handlePrevious = () => {
    if (currentPage > 1) {
      onPageChange(currentPage - 1);
    }
  };

  const handleNext = () => {
    if (currentPage < totalPages) {
      onPageChange(currentPage + 1);
    }
  };

  return (
    <div className={styles.pagination}>
      <div className={styles.paginationInfo}>
        <span>
          Affichage de {(currentPage - 1) * itemsPerPage + 1} à {Math.min(currentPage * itemsPerPage, totalItems)} sur {totalItems}
        </span>
        {onItemsPerPageChange && (
          <select 
            value={itemsPerPage} 
            onChange={(e) => onItemsPerPageChange(Number(e.target.value))}
            className={styles.itemsPerPage}
          >
            <option value={10}>10 par page</option>
            <option value={25}>25 par page</option>
            <option value={50}>50 par page</option>
            <option value={100}>100 par page</option>
          </select>
        )}
      </div>
      
      <div className={styles.paginationControls}>
        <button
          onClick={handlePrevious}
          disabled={currentPage === 1}
          className={styles.paginationButton}
        >
          ‹ Précédent
        </button>
        
        {startPage > 1 && (
          <>
            <button
              onClick={() => onPageChange(1)}
              className={styles.paginationButton}
            >
              1
            </button>
            {startPage > 2 && <span className={styles.ellipsis}>...</span>}
          </>
        )}
        
        {pages.map(page => (
          <button
            key={page}
            onClick={() => onPageChange(page)}
            className={`${styles.paginationButton} ${currentPage === page ? styles.active : ''}`}
          >
            {page}
          </button>
        ))}
        
        {endPage < totalPages && (
          <>
            {endPage < totalPages - 1 && <span className={styles.ellipsis}>...</span>}
            <button
              onClick={() => onPageChange(totalPages)}
              className={styles.paginationButton}
            >
              {totalPages}
            </button>
          </>
        )}
        
        <button
          onClick={handleNext}
          disabled={currentPage === totalPages}
          className={styles.paginationButton}
        >
          Suivant ›
        </button>
      </div>
    </div>
  );
}

