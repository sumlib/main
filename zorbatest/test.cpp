#include <iostream>
#include <sstream>

#include <zorba/zorba.h>
#include <simplestore/simplestore.h>

using namespace zorba;

bool
example_1(Zorba* aZorba)
{
  XQuery_t lQuery = aZorba->compileQuery("1+2");

  std::cout << lQuery << std::endl;

  return true;
}

bool
example_2(Zorba* aZorba)
{
  XQuery_t lQuery = aZorba->compileQuery("1+2");

  Iterator_t lIterator = lQuery->iterator();
  lIterator->open();

  Item lItem;
  while ( lIterator->next(lItem) ) {
    std::cout << lItem.getStringValue() << std::endl;
  }

  lIterator->close();

  return true;
}

bool
example_3(Zorba* aZorba)
{

  XQuery_t lQuery = aZorba->compileQuery("1 div 0"); 
  try {
    std::cout << lQuery << std::endl;
  } catch ( DynamicException& e ) {
    std::cerr <<  e << std::endl;
    return true;
  }

  return false;
}


bool
example_4(Zorba* aZorba)
{

  try {
    XQuery_t lQuery = aZorba->compileQuery("for $x in (1, 2, 3)");
  } catch ( StaticException& e ) {
    std::cerr <<  e << std::endl;
    return true;
  }

  return false;
}

bool
example_5(Zorba* aZorba)
{
  std::string lQueryString("for $i in (1,2,3)");
  std::istringstream lInStream(lQueryString);

  try {
    XQuery_t lQuery = aZorba->compileQuery(lInStream);

    std::cout << lQuery << std::endl;
  } catch ( StaticException& se ) {
    std::cerr << se << std::endl;
    return true;
  } catch ( DynamicException& de ) {
    std::cerr << de << std::endl;
  }

  return false;
}

bool
example_6(Zorba* aZorba)
{
  // set compiler hint => don't optimize
  Zorba_CompilerHints lHints;
  lHints.opt_level = ZORBA_OPT_LEVEL_O0;

  XQuery_t lQuery = aZorba->compileQuery("1+1", lHints);

  std::cout << lQuery << std::endl;

  return true;
}

bool
example_7()
{

  std::cout << Zorba::version() << std::endl;

  return true;
}

bool
example_8( Zorba * aZorba )
{
  XQuery_t lQuery = aZorba->createQuery();
  lQuery->setFileName("foo.xq");
  lQuery->compile("1+2");
  std::cout << lQuery << std::endl;
  return true;
}

bool
example_9( Zorba * aZorba )
{
  try {
    XQuery_t lQuery = aZorba->compileQuery("1+1");
    lQuery->compile("1+2");
  } catch (SystemException & e) {
    std::cout << e << std::endl;
    return true;
  }
  return false;
}

bool
example_10( Zorba * aZorba )
{
  XQuery_t lQuery1 = aZorba->compileQuery("declare variable $i external; 1 to $i");
  XQuery_t lQuery2 = lQuery1->clone();

  Iterator_t lIterator1 = lQuery1->iterator();
  DynamicContext* lDynContext1 = lQuery1->getDynamicContext();
  lDynContext1->setVariable("i", aZorba->getItemFactory()->createInteger(5));

  lIterator1->open();

  Item lItem;
  while ( lIterator1->next(lItem) ) {
    DynamicContext* lDynContext2 = lQuery2->getDynamicContext();
    lDynContext2->setVariable("i", lItem);

    Iterator_t lIterator2 = lQuery2->iterator();
    
    lIterator2->open();
    while ( lIterator2->next(lItem) ) {
      std::cout << lItem.getStringValue();
    }
    lIterator2->close();
    std::cout << std::endl;
  }

  lIterator1->close();

  return true;
}

bool
example_11( Zorba * aZorba )
{
  StaticContext_t lContextWithProlog = aZorba->createStaticContext();
  String prolog (
"declare variable $x := 2;\n"
"declare function local:f ($n) { $x + $n };\n"
);
  const Zorba_CompilerHints_t hints;
  lContextWithProlog->loadProlog(prolog, hints);
  
  XQuery_t lQuery = aZorba->compileQuery("local:f ($x + 1)", lContextWithProlog);
  std::cout << lQuery << std::endl;
  return true;
}

bool
example_12(Zorba* aZorba)
{
  XQuery_t lQuery = aZorba->compileQuery("<a><b attr='1'/><b attr='2'/></a>");

  Iterator_t lIterator = lQuery->iterator();
  lIterator->open();

  Item lItem;
  while ( lIterator->next(lItem) ) {
    Iterator_t lChildIter = lItem.getChildren();

    lChildIter->open();
    Item lChild;
    while (lChildIter->next(lChild)) {

      Item lNodeName;
      lChild.getNodeName(lNodeName);
      std::cout << "node name " << lNodeName.getStringValue() << std::endl;
      Iterator_t lAttrIter = lChild.getAttributes();
      
      lAttrIter->open();

      Item lAttr;
      while (lAttrIter->next(lAttr)) {
        std::cout << "  attribute value " << lAttr.getStringValue() << std::endl;
      }
      lAttrIter->close();
    }
    lChildIter->close();
  }

  lIterator->close();

  return true;
}

bool
example_13(Zorba* aZorba)
{
  XQuery_t lQuery = aZorba->compileQuery("while (fn:true()) {()};");
  lQuery->setTimeout(1);

  try {
    std::cout << lQuery << std::endl;
  } catch (zorba::SystemException&) {
    std::cout << "query interrputed after 1 second" << std::endl;
    return true;
  }

  return false;
}


int 
main(int argc, char* argv[])
{
  simplestore::SimpleStore* lStore = simplestore::SimpleStoreManager::getStore();
  Zorba *lZorba = Zorba::getInstance(lStore);

  char* query = "for $tablet in .//tablet \n let $seq0 := (\n  for $edge_end in $tablet//edge\n  for $edge_start in $tablet//edge\n  where\n  (\n    fn:matches($edge_start,'^uruda$')    and ($edge_end[@node1=$edge_start/@node2] \n    and fn:matches($edge_end,'^bi$'))\n  )\n  return\n <seq0> {$edge_start/@node1} {$edge_end/@node2} </seq0>\n)\nwhere \n      $seq0\nand\n \n(fn:matches($tablet/collection,'^.*deras.*$'))\nreturn <tablet>\n  {$tablet/idCDLI} \n  {$tablet/publication}\n  {$tablet/provenience}\n \n{$tablet/period}\n  {$tablet/measurements}\n  {$tablet/genre}\n  {$tablet/subgenre}\n  {$tablet/collection}\n  {$tablet/museum}\n \n{$tablet/text/show}\n  <seq>\n    {$seq0}\n  </seq> \n</tablet>\n";
  
  char* query2 = "for $tablet in .//tablet \n return <tablet>\n  {$tablet/idCDLI} \n  {$tablet/publication}\n  {$tablet/provenience}\n \n{$tablet/period}\n  {$tablet/measurements}\n  {$tablet/genre}\n  {$tablet/subgenre}\n  {$tablet/collection}\n  {$tablet/museum}\n \n{$tablet/text/show}\n  <seq>\n    cos\n  </seq> \n</tablet>\n";

  //char* query = "1+1";
  
  //std::cout << query << std::endl;
  
//  XQuery_t lQuery = lZorba->compileQuery("<a><b attr='1'/><b attr='2'/></a>");

{
//    StaticContext_t lStaticContext = lZorba->createStaticContext();
    //lStaticContext->setBaseURI("file:///home/asia/Dokumenty/zorbatest/tablets.xml");
  
   try {
       std::cout << "compiling query" << std::endl;
      //XQuery_t lQuery = lZorba->compileQuery("doc('/home/asia/Dokumenty/zorbatest/tablets.xml')/tablets/tablet", lStaticContext);
       XQuery_t lQuery = lZorba->compileQuery(query2);
       DynamicContext* lDynamicContext = lQuery->getDynamicContext();
       
       lDynamicContext->setContextItemAsDocument("file:///home/asia/Dokumenty/zorbatest/tablets.xml");
       
       
      std::cout << "compiled" << std::endl;
	  try {
	
	    std::cout << lQuery << std::endl;
	
	  } catch (DynamicException &e) {
	    std::cerr << e << std::endl;
	    return false;
	  }
      
    } catch (StaticException &se) {
      std::cerr << se << std::endl;
      return true;
    }
  
    //XQuery_t lQuery = lZorba->compileQuery(query, lStaticContext);
    
    
//   try {
// 
//     std::cout << lQuery << std::endl;
// 
//   } catch (DynamicException &e) {
//     std::cerr << e << std::endl;
//     return false;
//   }

//   Iterator_t lIterator = lQuery->iterator();
//   lIterator->open();
// 
//   Item lItem;
//   while ( lIterator->next(lItem) ) {
//     Iterator_t lChildIter = lItem.getChildren();
// 
//     lChildIter->open();
//     Item lChild;
//     while (lChildIter->next(lChild)) {
// 
//       Item lNodeName;
//       lChild.getNodeName(lNodeName);
//       std::cout << "node name " << lNodeName.getStringValue() << std::endl;
//       Iterator_t lAttrIter = lChild.getAttributes();
//       
//       lAttrIter->open();
// 
//       Item lAttr;
//       while (lAttrIter->next(lAttr)) {
//         std::cout << "  attribute value " << lAttr.getStringValue() << std::endl;
//       }
//       lAttrIter->close();
//     }
//     lChildIter->close();
//   }
// 
//   lIterator->close();
}
  //example_12(lZorba);

  lZorba->shutdown();
  simplestore::SimpleStoreManager::shutdownStore(lStore);
  return 0;
}
