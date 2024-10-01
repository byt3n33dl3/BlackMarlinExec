#include <stdio.h>
#include <stdlib.h>
typedef struct node
{
    int ipAdd;
    int dataPacket;
    struct node *left;
    struct node *right;
    struct node *parent;
} node;

typedef struct splay_tree
{
    struct node *root;
} splay_tree;

node *new_node(int ipAdd)
{
    node *n = malloc(sizeof(node));
    n->ipAdd = ipAdd;
    n->parent = NULL;
    n->right = NULL;
    n->left = NULL;
    return n;
}

splay_tree *new_splay_tree()
{
    splay_tree *t = malloc(sizeof(splay_tree));
    t->root = NULL;
    return t;
}

node *maximum(splay_tree *t, node *x)
{
    while (x->right != NULL)
        x = x->right;
    return x;
}

void left_rotate(splay_tree *t, node *x)
{
    node *y = x->right;
    x->right = y->left;
    if (y->left != NULL)
    {
        y->left->parent = x;
    }
    y->parent = x->parent;
    if (x->parent == NULL)
    {
        t->root = y;
    }
    else if (x == x->parent->left)
    {
        x->parent->left = y;
    }
    else
    {
        x->parent->right = y;
    }
    y->left = x;
    x->parent = y;
}

void right_rotate(splay_tree *t, node *x)
{
    node *y = x->left;
    x->left = y->right;
    if (y->right != NULL)
    {
        y->right->parent = x;
    }
    y->parent = x->parent;
    if (x->parent == NULL)
    {
        t->root = y;
    }
    else if (x == x->parent->right)
    {
        x->parent->right = y;
    }
    else
    {
        x->parent->left = y;
    }
    y->right = x;
    x->parent = y;
}

void splay(splay_tree *t, node *n)
{
    while (n->parent != NULL)
    {
        if (n->parent == t->root)
        {
            if (n == n->parent->left)
            {
                right_rotate(t, n->parent);
            }
            else
            {
                left_rotate(t, n->parent);
            }
        }
        else
        {
            node *p = n->parent;
            node *g = p->parent;
            if (n->parent->left == n && p->parent->left == p)
            {
                right_rotate(t, g);
                right_rotate(t, p);
            }
            else if (n->parent->right == n && p->parent->right == p)
            {
                left_rotate(t, g);
                left_rotate(t, p);
            }
            else if (n->parent->right == n && p->parent->left == p)
            {
                left_rotate(t, p);
                right_rotate(t, g);
            }
            else if (n->parent->left == n && p->parent->right == p)
            {
                right_rotate(t, p);
                left_rotate(t, g);
            }
        }
    }
}

void insert(splay_tree *t, node *n)
{
    node *y = NULL;
    node *temp = t->root;
    while (temp != NULL)
    {
        y = temp;
        if (n->ipAdd < temp->ipAdd)
            temp = temp->left;
        else
            temp = temp->right;
    }
    n->parent = y;
    if (y == NULL)
        t->root = n;
    else if (n->ipAdd < y->ipAdd)
        y->left = n;
    else
        y->right = n;
    splay(t, n);
}

node *search(splay_tree *t, node *n, int x)
{
    if (x == n->ipAdd)
    {
        splay(t, n);
        return n;
    }
    else if (x < n->ipAdd)
        return search(t, n->left, x);
    else if (x > n->ipAdd)
        return search(t, n->right, x);
    else
        return NULL;
}

void inorder(splay_tree *t, node *n, char *cmn)
{
    if (n != NULL)
    {
        inorder(t, n->left, cmn);
        printf("%s%d -> %d\n", cmn, n->ipAdd,
               n->dataPacket);
        inorder(t, n->right, cmn);
    }
}

int main()
{
    char *cmn = "192.168.3.";
    splay_tree *t = new_splay_tree();
    node *a, *b, *c, *d, *e, *f, *g, *h, *i, *j, *k, *l, *m;
    a = new_node(104);
    b = new_node(112);
    c = new_node(117);
    d = new_node(124);
    e = new_node(121);
    f = new_node(108);
    g = new_node(109);
    h = new_node(111);
    i = new_node(122);
    j = new_node(125);
    k = new_node(129);
    insert(t, a);
    insert(t, b);
    insert(t, c);
    insert(t, d);
    insert(t, e);
    insert(t, f);
    insert(t, g);
    insert(t, h);
    insert(t, i);
    insert(t, j);
    insert(t, k);
    int x;
    int find[11] = {104, 112, 117, 124, 121, 108, 109, 111,
                    122, 125, 129};
    int add[11] = {a, b, c, d, e, f, g, h, i, j, k};
    srand(time(0));
    for (x = 0; x < 11; x++)
    {
        int data = rand() % 200;
        node *temp = search(t, add[x], find[x]);
        if (temp != NULL)
        {
            temp->dataPacket = data;
        }
    }
    printf("IP ADDRESS -> DATA PACKET\n");
    inorder(t, t->root, cmn);
    return 0;
}
