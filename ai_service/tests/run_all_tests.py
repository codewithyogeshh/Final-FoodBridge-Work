"""
FoodBridge AI Microservice - Master Test Suite Runner
Runs all unit and integration tests across all 4 AI features and security.
"""
import unittest
import sys
import os

# Set path to include ai_service root
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.insert(0, parent_dir)


def run_tests():
    loader = unittest.TestLoader()
    suite = loader.discover(start_dir=current_dir, pattern="test_*.py")
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    print("\n" + "=" * 60)
    print(f"FOODBRIDGE AI MICROSERVICE TEST SUMMARY:")
    print(f"Tests Run: {result.testsRun}")
    print(f"Failures:  {len(result.failures)}")
    print(f"Errors:    {len(result.errors)}")
    print("=" * 60)
    
    if not result.wasSuccessful():
        sys.exit(1)
    print("ALL AI MICROSERVICE TESTS PASSED SUCCESSFULLY!")


if __name__ == "__main__":
    run_tests()

