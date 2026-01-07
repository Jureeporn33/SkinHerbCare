// controllers/analysisController.js

/**
 * @desc    Get sales data for the last 6 months
 * @route   GET /api/analysis/sales
 * @access  Private/Admin
 */
export const getSalesData = async (req, res) => {
  try {
    // In a real application, you would fetch and process this data from your database.
    // For now, we'll return mock data that matches the frontend's needs.
    const salesData = {
      labels: ['มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.'],
      data: [12000, 19000, 15000, 25000, 22000, 31000],
    };

    res.status(200).json({
      success: true,
      data: salesData,
    });
  } catch (error) {
    console.error('Error fetching sales data:', error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};

/**
 * @desc    Get product distribution by category
 * @route   GET /api/analysis/categories
 * @access  Private/Admin
 */
export const getCategoryData = async (req, res) => {
  try {
    // Again, this would come from a database query.
    const categoryData = {
      labels: ['เซรั่ม', 'ครีม', 'ทำความสะอาด', 'โทนเนอร์', 'อื่นๆ'],
      data: [45, 25, 20, 10, 5], // Added 'อื่นๆ'
    };

    res.status(200).json({
      success: true,
      data: categoryData,
    });
  } catch (error) {
    console.error('Error fetching category data:', error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};
